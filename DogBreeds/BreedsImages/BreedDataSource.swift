//
//  BreedDataSource.swift
//  Breeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

final class BreedDataSource {

    private typealias DataSource = UICollectionViewDiffableDataSource<Breed.Models.Section, Breed.Models.Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Breed.Models.Section, Breed.Models.Item>

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
    func updateSnapshot(_ items: [Breed.Models.Item], animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            switch item {
            case let .item(state):
                let cell: BreedCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.wasSelected = !state.isLikeHidden
                cell.state = state
                return cell
            }
        }
    }
}

// MARK: - Private
private extension BreedDataSource {

    func registerReusable(in collectionView: UICollectionView) {
        collectionView.register(cellType: BreedCollectionViewCell.self)
    }
}

// MARK: - Layout
private extension BreedDataSource {

    func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { index, _ -> NSCollectionLayoutSection? in
            let fractionalWidth: CGFloat = 0.3
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fractionalWidth),
                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(fractionalWidth / 1.5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let spacing = (self.collectionView.frame.width * (1 - fractionalWidth * 3)) / 4
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
