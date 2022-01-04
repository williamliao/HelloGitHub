//
//  SettingViewModel.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/4.
//

import UIKit

class SettingViewModel {
    
    private let dataLoader: DataLoader
    private(set) var isFetching = false
    
    var user: UserAccount!
    var avatarImage: UIImage?
    
    var reloadData: (() -> Void)?
    var showError: ((_ error:NetworkError) -> Void)?
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
}

// MARK: - Public
extension SettingViewModel {
    
    func fetchUserInfo() async {
        async let _ = await fetchUser()
        async let _ = await fetchUserImage()
        reloadData?()
    }
    
    func fetchUser() async {
        
        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        do {
            let result = try await dataLoader.fetch(EndPoint.fetchUsers(), decode: {json -> UserAccount? in
                guard let feedResult = json as? UserAccount else { return  nil }
                return feedResult
            })
            
            isFetching = false
            switch result {
                case .success(let user):
                
                    self.user = user
                    
                case .failure(let error):
                    showError?(error)
            }
            
        }  catch  {
            print("fetchUser error \(error)")
            showError?(error as? NetworkError ?? NetworkError.unKnown)
        }
    }
    
    func fetchUserImage() async {
        
        if let cacheImage = getImageFromDisk() {
            avatarImage = cacheImage
        } else {
            if #available(iOS 15.0, *) {
                do {
                    
                    guard let avatar_url = self.user.avatar_url, let url = URL(string: avatar_url) else {
                        return
                    }
                    
                    let image = try await self.downloadImage(url)
                    
                    guard let image = image, let image = self.resizeImage(at: image) else {
                        return
                    }
                    
                    Task.detached(priority: .background) { [weak self] in
                        await self?.storeImageInDisk(image: image)
                    }

                    avatarImage = image
                    
                } catch  {
                    print("downloadImage error \(error)")
                }
            } else {
                // Fallback on earlier versions
                guard let avatar_url = self.user.avatar_url, let url = URL(string: avatar_url) else {
                    return
                }
                
                self.downloaded(from: url)
            }
        }
    }
}

// MARK: - Private
extension SettingViewModel {
    
    @available(iOS 15.0, *)
    func downloadImage(_ imageUrl: URL?) async throws -> UIImage? {
        
        guard let imageUrl = imageUrl else {
            return nil
        }

        let imageRequest = URLRequest(url: imageUrl)
        let (data, imageResponse) = try await URLSession.shared.data(for: imageRequest)
        guard let image = UIImage(data: data), (imageResponse as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidImage
        }
        return image
    }
    
    func downloaded(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            
            DispatchQueue.global(qos: .background).async {

                guard let resizeImage = self.resizeImage(at: image) else {
                    return
                }
                
                DispatchQueue.main.async() { [weak self] in
                    
                    self?.avatarImage = resizeImage
                }
            }
            
            Task.detached(priority: .background) { [weak self] in
                await self?.storeImageInDisk(image: image)
            }
            
        }.resume()
    }
    
    func downloaded(from link: String) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url)
    }
    
    func resizeImage(at image: UIImage) -> UIImage? {
        let resizeRect = calcImageSize(at: image, targetSize: CGSize(width: 100, height: 100))
        
        let renderer = UIGraphicsImageRenderer(size: resizeRect.size)
            return renderer.image { (context) in
            image.draw(in: resizeRect)
        }
    }
    
    func calcImageSize(at image: UIImage, targetSize: CGSize) -> CGRect {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        return CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    }
    
    func storeImageInDisk(image: UIImage) async {
        guard
            let imageData = image.pngData(),
            let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        let imageUrl = cachesUrl.appendingPathComponent("Profile")
        try? imageData.write(to: imageUrl)
    }
    
    func getImageFromDisk() -> UIImage? {
        guard let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let imageUrl = cachesUrl.appendingPathComponent("Profile")
        
        guard let image = UIImage(contentsOfFile: imageUrl.path) else {
            return nil
        }
        
        return image
    }
}
