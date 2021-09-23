//
//  SplitViewController.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/05.
//

import UIKit

final class SplitViewController: UISplitViewController {
    private let detailViewController = MemoDetailViewController()
    private let primaryViewController = MemoListViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.decideSpliveVCPreferences()
        self.delegate = self
    }
    
    private func decideSpliveVCPreferences() {
        self.preferredDisplayMode = .oneBesideSecondary
        self.preferredSplitBehavior = .displace
        self.setViewController(primaryViewController, for: .primary)
        self.setViewController(detailViewController, for: .secondary)
    }
}

extension SplitViewController {
    func presentMemo(location: Int) {
        let memo = selectedMemo(location)
        self.detailViewController.presentMemo(memo, location)
        self.show(.secondary)
    }
    
    private func selectedMemo(_ index: Int) -> Memo {
        CoreDataManager.shared.memos[index]
    }
    
    func delete(_ memo: Int) {
        CoreDataManager.shared.deletMemo(memo) {
            self.primaryViewController.updateTableView()
        }
        self.show(.primary)
    }
    
    func creatNewMemo(_ location: Int) {
        CoreDataManager.shared.createMemo {
            self.primaryViewController.updateTableView()
        }
        let memo = CoreDataManager.shared.memos[location]
        self.detailViewController.presentMemo(memo, location)
        self.show(.secondary)
    }
    
    func updateMemo(_ memo: String, _ location: Int) {
        CoreDataManager.shared.updateMemo(content: memo, location: location) {
            self.primaryViewController.updateTableView()
        }
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        svc.presentsWithGesture = false
    }
}
