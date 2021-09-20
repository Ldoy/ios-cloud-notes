//
//  CloudNotes - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class PrimaryViewController: UIViewController {
    private let tableView = UITableView()
    private let tableViewDataSource = MainVCTableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: CellId.defaultCell.description)
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
        setNavigationBarItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        print(#function)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.frame = view.bounds
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }
}

extension PrimaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let secondVC = splitViewController?.viewController(for: .secondary) as? SecondaryViewController
        let lineBreaker = "\n"
        let emptyString = ""
        
        secondVC.flatMap {
            $0.textView.text = "\(MemoDataHolder.list?[indexPath.row].title ?? emptyString)" + lineBreaker + lineBreaker + "\(MemoDataHolder.list?[indexPath.row].body ?? emptyString)"
            $0.textViewDelegate.indexPath = indexPath
            $0.textViewDelegate.tableView = tableView
            splitViewController?.show(.secondary)
        }
    }
    

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        tableView.reloadData()
//    }
    
}

extension PrimaryViewController {
    private func setNavigationBarItem() {
        let navigationBarTitle = "메모"
        title = navigationBarTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: #selector(didTabButton))
    }
    
    @objc func didTabButton() {
        let detailVC = SecondaryViewController()
        showDetailViewController(detailVC, sender: nil)
    }
}
