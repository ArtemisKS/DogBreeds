//
//  NetworkingError.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

enum NetworkingError: Error {
    case server(status: Int, message: String?)
    case unknown
}

// MARK: - LocalizedError
extension NetworkingError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case let .server(status, message):
            return "Internal server error\n code - \(status)\n message - \(message ?? "N/A"))"
        default:
            return String(describing: self)
        }
    }
}
