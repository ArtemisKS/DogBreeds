//
//  Endpoint.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dog.ceo"
        components.path = "/api" + path
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }

        return url
    }

    var headers: [String: Any] {
        [:]
    }
}

extension Endpoint {

    static func makeEndpoint(_ endpoint: Endpoints) -> Self {
        Endpoint(path: endpoint.value)
    }

    static func users(count: Int) -> Self {
        return Endpoint(path: "/user",
                        queryItems: [
                            URLQueryItem(name: "limit",
                                         value: "\(count)")
            ]
        )
    }
}
