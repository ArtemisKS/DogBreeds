//
//  NetworkController.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation
import Combine

protocol NetworkControllerProtocol: AnyObject {
    typealias Headers = [String: Any]

    func fetch<T>(type: T.Type,
                  url: URL,
                  headers: Headers) -> AnyPublisher<T, Error> where T: Decodable
}

final class NetworkController: NetworkControllerProtocol {

    func fetch<T: Decodable>(type: T.Type,
                             url: URL,
                             headers: Headers) -> AnyPublisher<T, Error> {

        var urlRequest = URLRequest(url: url)

        headers.forEach { (key, value) in
            if let value = value as? String {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global())
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

}
