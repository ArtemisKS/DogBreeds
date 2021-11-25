//
//  BreedsController.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation
import Combine

struct BreedsMapper {

    static func map(_ model: BreedsListModel) -> [BreedsList.Models.ItemModel] {
        guard StatusChecker.success(model.status) else { return [] }
        return model.message.map { (key: String, value: [String]) in
                .init(text: key, subtypes: value)
        }
    }
}

protocol BreedsControllerProtocol: AnyObject {
    var networkController: NetworkControllerProtocol { get }

    func getBreedsList() -> AnyPublisher<[BreedsList.Models.ItemModel], Error>
    func getBreedImages(_ breed: String) -> AnyPublisher<[String], Error>
}

final class BreedsController: BreedsControllerProtocol {

    let networkController: NetworkControllerProtocol

    init(networkController: NetworkControllerProtocol) {
        self.networkController = networkController
    }

    func getBreedsList() -> AnyPublisher<[BreedsList.Models.ItemModel], Error> {
        let endpoint: Endpoint = .makeEndpoint(.allBreeds)

        return networkController.fetch(
            type: BreedsListModel.self,
            url: endpoint.url,
            headers: endpoint.headers)
            .map { BreedsMapper.map($0) }
            .eraseToAnyPublisher()
    }

    func getBreedImages(_ breed: String) -> AnyPublisher<[String], Error> {
        let endpoint: Endpoint = .makeEndpoint(.breedImages(breed))

        return networkController.fetch(
            type: BreedsImagesModel.self,
            url: endpoint.url,
            headers: endpoint.headers)
            .map { $0.message }
            .eraseToAnyPublisher()
    }
}
