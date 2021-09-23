//
//  CloudNotes - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreData

final class MemoListViewController: UIViewController {
    private lazy var tableView = UITableView()
    private let tableViewDataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTableViewPropertyAndMethod()
        self.setNavigationBarItem()
    }
    
    //MARK: Set TableView Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.frame = view.bounds
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    func updateTableView() {
        self.tableView.reloadData()
    }
}

extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memoIndex = indexPath.row
        if let splitViewController = self.splitViewController as? SplitViewController {
            splitViewController.presentMemo(location: memoIndex)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = [
            UIContextualAction(
                style: .destructive,
                title: SelectOptions.delete.literal,
                handler: { [self] _, _, _ in
                    if let splitViewController = self.splitViewController as? SplitViewController {
                        // 여기 삭제됨
                        splitViewController.delete(indexPath.row)
                    }
                }),
            UIContextualAction(
                style: .normal,
                title: SelectOptions.share.literal,
                handler: { action, view, completionHandler in
                    print("share action구현하기 ")
                })
        ]
        
        return UISwipeActionsConfiguration(actions: actions)
    }
}

extension MemoListViewController {
    private func setNavigationBarItem() {
        let navigationBarTitle = "메모"
        self.title = navigationBarTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTabAddButton))
    }
    
    private func setTableViewPropertyAndMethod() {
        self.view.addSubview(tableView)
        self.tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.identifier)
        self.tableView.dataSource = tableViewDataSource
        self.tableView.delegate = self
    }
    
    @objc func didTabAddButton() {
        let newMemoIndex = self.tableView.numberOfRows(inSection: .zero)
        if let splitViewController = self.splitViewController as? SplitViewController {
            splitViewController.creatNewMemo(newMemoIndex)
        }
    }
}
