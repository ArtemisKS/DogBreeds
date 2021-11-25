//
//  BreedsListDataSource.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

final class BreedsListDataSource {

    private enum Defaults {
        static let cornerRadius: CGFloat = 8
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<BreedsList.Models.Section, BreedsList.Models.Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<BreedsList.Models.Section, BreedsList.Models.Item>

    // MARK: - Properties
    private unowned var collectionView: UICollectionView
    private lazy var dataSource = makeDataSource()

    // MARK: - Initializators
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = dataSource
        registerReusable(in: collectionView)
    }

    // MARK: - Interface
    func updateSnapshot(_ items: [BreedsList.Models.Item], animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func makeDataSource() -> DataSource {
        let source = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            switch item {
            case let .item(state):
                let cell: BreedsListCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.state = state
                cell.round(with: Defaults.cornerRadius)
                cell.backgroundColor = .customVeryLightBlue
                return cell
            }
        }
        return source
    }
}

// MARK: - Private
private extension BreedsListDataSource {

    func registerReusable(in collectionView: UICollectionView) {
        collectionView.register(cellType: BreedsListCollectionViewCell.self)
    }
}

// MARK: - Layout
private extension BreedsListDataSource {

    func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { index, _ -> NSCollectionLayoutSection? in
            let fractionalWidth: CGFloat = 0.4
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fractionalWidth),
                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(72))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let spacing = (self.collectionView.frame.width * (1 - fractionalWidth * 2)) / 3
            group.interItemSpacing = .fixed(spacing)
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(
                leading: .fixed(spacing),
                top: .fixed(spacing),
                trailing: .fixed(spacing),
                bottom: .fixed(0)
            )

            let section = NSCollectionLayoutSection(group: group)

            return section
        }
    }
}

