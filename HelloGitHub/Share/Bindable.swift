//
//  Bindable.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import Foundation

class Bindable<Value> {
    private var observations = [(Value) -> Bool]()
    private var lastValue: Value?

    init(_ value: Value? = nil) {
        lastValue = value
    }
}

private extension Bindable {
    func addObservation<O: AnyObject>(
        for object: O,
        handler: @escaping (O, Value) -> Void
    ) {
        // If we already have a value available, we'll give the
        // handler access to it directly.
        lastValue.map { handler(object, $0) }

        // Each observation closure returns a Bool that indicates
        // whether the observation should still be kept alive,
        // based on whether the observing object is still retained.
        observations.append { [weak object] value in
            guard let object = object else {
                return false
            }

            handler(object, value)
            return true
        }
    }
}

extension Bindable {
    func update(with value: Value) {
        lastValue = value
        observations = observations.filter { $0(value) }
    }
}

extension Bindable {
    func bind<O: AnyObject, T>(
        _ sourceKeyPath: KeyPath<Value, T>,
        to object: O,
        _ objectKeyPath: ReferenceWritableKeyPath<O, T>
    ) {
        addObservation(for: object) { object, observed in
            let value = observed[keyPath: sourceKeyPath]
            object[keyPath: objectKeyPath] = value
        }
    }
}

extension Bindable {
    func bind<O: AnyObject, T>(
        _ sourceKeyPath: KeyPath<Value, T>,
        to object: O,
        // This line is the only change compared to the previous
        // code sample, since the key path we're binding *to*
        // might contain an optional.
        _ objectKeyPath: ReferenceWritableKeyPath<O, T?>
    ) {
        addObservation(for: object) { object, observed in
            let value = observed[keyPath: sourceKeyPath]
            object[keyPath: objectKeyPath] = value
        }
    }
}

extension Bindable {
    func bind<O: AnyObject, T, R>(
        _ sourceKeyPath: KeyPath<Value, T>,
        to object: O,
        _ objectKeyPath: ReferenceWritableKeyPath<O, R?>,
        transform: @escaping (T) -> R?
    ) {
        addObservation(for: object) { object, observed in
            let value = observed[keyPath: sourceKeyPath]
            let transformed = transform(value)
            object[keyPath: objectKeyPath] = transformed
        }
    }
}
