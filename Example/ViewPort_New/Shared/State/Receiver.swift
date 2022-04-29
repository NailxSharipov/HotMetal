//
//  Receiver.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import Combine

struct Receiver<T: ObservableObject> {
    
    private let cancellable: AnyCancellable?
    private (set) weak var object: T?
    
    init() {
        cancellable = nil
        object = nil
    }
    
    init(_ object: T, willChange: @escaping (T) -> ()) {
        self.object = object
        self.cancellable = object.objectWillChange.sink { [weak object] _ in
            guard let object = object else { return }
            willChange(object)
        }
    }
}
