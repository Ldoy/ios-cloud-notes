//
//  SplitViewController.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/05.
//

import UIKit
import CoreData

class SplitViewController: UISplitViewController {
    private let detailVC = SecondaryViewController()
    private let primaryVC = PrimaryViewController()
    private let splitViewDelegate = SplitViewDelegate()
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        decideSpliveVCPreferences()
        self.delegate = splitViewDelegate
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
    }
}

extension SplitViewController {
    private func decideSpliveVCPreferences() {
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .displace
        setViewController(primaryVC, for: .primary)
        setViewController(detailVC, for: .secondary)
    }
}
