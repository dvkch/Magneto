//
//  ObservedObject.swift
//  SYKit
//
//  Created by Stanislas Chevallier on 13/05/2020.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation

typealias ObservationRef = NSObject
typealias ObservationClosure<T> = (T, T) -> Void

class ObservedObject<T> {

    init(initial: T) {
        underlying = initial
    }

    private class Observer<T> {
        weak var ref: ObservationRef?
        let closure: ObservationClosure<T>
        
        init(ref: ObservationRef, closure: @escaping ObservationClosure<T>) {
            self.ref = ref
            self.closure = closure
        }
    }

    // MARK: Internal properties
    private var underlying: T
    private var observers: Array<Observer<T>> = []

    var value: T {
        get { underlying }
        set {
            setValue(newValue, skipCallbacks: false)
        }
    }

    func setValue(_ value: T, skipCallbacks: Bool = false) {
        let prevValue = underlying
        underlying = value

        if skipCallbacks { return }

        DispatchQueue.main.async {
            self.observers
                .filter { $0.ref != nil }
                .forEach { $0.closure(prevValue, value) }
        }
    }

    func addObserver(ref: ObservationRef, callNow: Bool = false, observer: @escaping ObservationClosure<T>) {
        let obs = Observer(ref: ref, closure: observer)
        observers.append(obs)
        if (callNow) {
            observer(value, value)
        }
    }

    func removeObserver(ref: ObservationRef) {
        observers.removeAll(where: { $0.ref == nil || $0.ref == ref })
    }
}
