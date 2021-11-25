//
//  ActionSheetDataSource.swift
//  CustomActionSheet
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

final class ActionSheetDataSource {

    fileprivate typealias DataSource = UITableViewDiffableDataSource<ActionSheet.Models.Section, ActionSheet.Models.Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ActionSheet.Models.Section, ActionSheet.Models.Item>

    // MARK: - Properties
    private let tableView: UITableView
    private lazy var dataSource = makeDataSource()

    // MARK: - Initializators
    init(tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = dataSource
        registerReusable(in: tableView)
    }

    // MARK: - Interface
    func updateSnapshot(_ items: [ActionSheet.Models.Item], animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - Private
private extension ActionSheetDataSource {

    func registerReusable(in tableView: UITableView) {
        tableView.register(cellType: ActionSheetTableViewCell.self)
    }
}

// MARK: - DataSource
private extension ActionSheetDataSource {

    func makeDataSource() -> DataSource {
        let source = DataSource(tableView: tableView) { tableView, indexPath, item -> UITableViewCell? in
            switch item {
            case let .item(state):
                let cell: ActionSheetTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.state = state
                return cell
            }
        }
        source.defaultRowAnimation = .fade
        return source
    }
}

