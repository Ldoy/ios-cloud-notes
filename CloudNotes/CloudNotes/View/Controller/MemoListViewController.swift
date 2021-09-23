//
//  CloudNotes - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreData

final class MemoListViewController: UIViewController, CoreDataAccessible {
    private lazy var tableView = UITableView()
    private let tableViewDataSource = MemoListTableViewDataSource()
    private let context = MemoDataManager.context
    private var memos = MemoDataManager.memos
    
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
}

extension MemoListViewController: UITableViewDelegate {
    //MARK: - Transfer Data to MemoDetailVC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.giveDataToSecondaryVC(indexPath, tableView)
        deselectCurrentCell(tableView)
        self.splitViewController?.show(.secondary)
    }
    
    private func giveDataToSecondaryVC(_ indexPath: IndexPath, _ tableView: UITableView) {
        let secondVC = splitViewController?.viewController(for: .secondary) as? MemoDetailViewController
        
        let transferedText = "\(self.memos[indexPath.row].title ?? "")" + "\(self.memos[indexPath.row].body ?? "")"
        let tableViewIndexPathHolder = TextViewRelatedDataHolder(indexPath: indexPath, tableView: tableView, textViewText: transferedText)
        secondVC?.configure(tableViewIndexPathHolder)
    }
    
    private func deselectCurrentCell(_ tableView: UITableView) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    //MARK: - Options after cell swipping
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = [
            UIContextualAction(
                style: .destructive,
                title: SelectOptions.delete.literal,
                handler: { [weak self] action, view, completionHandler in
                    guard let `self` = self else {
                        return
                    }
                    let memoToRemove = self.memos[indexPath.row]
                    self.deleteSaveFetchData(self.context, memoToRemove, tableView)
                    self.memos.remove(at: indexPath.row)
                    
                    let secondVC = self.splitViewController?.viewController(for: .secondary) as? MemoDetailViewController
                    let holder = TextViewRelatedDataHolder(indexPath: indexPath, tableView: tableView, textViewText: nil)
                    secondVC?.configure(holder)
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
    
    //MARK: - Called after tab addButton
    @objc func didTabAddButton() {
        //let todayDate = Date().makeCurrentDateInt64Data()
        let newMemo = Memo(context: self.context)
        newMemo.lastModifiedDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        newMemo.title = " "
        
        self.memos.append(newMemo)
        self.saveCoreData(context)
        
        guard let secondVC = self.splitViewController?.viewController(for: .secondary) as? MemoDetailViewController else {
            return
        }
        
        //MARK: Make Insert Location IndexPath
        let totalRows = self.tableView.numberOfRows(inSection: .zero)
        let newIndexPath = IndexPath(row: totalRows, section: .zero)
        
        //MARK: Give Data to MemoDetailVC
        let emptyHolder = TextViewRelatedDataHolder(indexPath: newIndexPath, tableView: tableView, textViewText: nil)
        secondVC.configure(emptyHolder)
        
        self.fetchCoreDataItems(context, tableView)
        self.splitViewController?.show(.secondary)
    }
}
