//
//  Queue.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

struct Queue<T> {
    private var array = [T]()

    var isEmpty: Bool {
        array.isEmpty
    }

    var count: Int {
        array.count
    }

    mutating func enqueue(_ element: T) {
        array.append(element)
    }

    mutating func dequeue() -> T? {
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
