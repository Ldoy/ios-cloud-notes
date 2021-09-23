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
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
            return .primary
        }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        svc.presentsWithGesture = false
    }
}

extension SplitViewController {
    private func decideSpliveVCPreferences() {
        self.preferredDisplayMode = .oneBesideSecondary
        self.preferredSplitBehavior = .displace
        self.setViewController(primaryViewController, for: .primary)
        self.setViewController(detailViewController, for: .secondary)
    }
}
