//
//  MainVCTableViewDataSourceViewController.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/02.
//

import UIKit

final class TableViewDataSource: NSObject, UITableViewDataSource {
    static let identifier = "cell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataManager.shared.memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.identifier, for: indexPath) as? MemoListTableViewCell else {
            return UITableViewCell()
        }
        
        let memo = CoreDataManager.shared.memos[indexPath.row]
        let cellContent = CellContentDataHolder(title: memo.title ?? "", date: memo.lastModifiedDate ?? Date(), body: memo.body ?? "")
        cell.configure(cellContent)
        
        return cell
    }
}
