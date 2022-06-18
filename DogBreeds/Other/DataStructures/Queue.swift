//
//  Queue.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

class Queue<T> {
    private var array = [T]()

    var isEmpty: Bool {
        array.isEmpty
    }

    var count: Int {
        array.count
    }

    func enqueue(_ element: T) {
        array.append(element)
    }

    func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }

    var front: T? {
        array.first
    }
}
