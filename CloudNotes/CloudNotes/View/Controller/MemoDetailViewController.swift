//
//  DetailViewController.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/05.
//

import UIKit
import CoreData

final class MemoDetailViewController: UIViewController, CoreDataAccessible {
    private lazy var textView = UITextView()
    private let context = MemoDataManager.context
    private var holder: TextViewRelatedDataHolder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(textView)
        self.textView.delegate = self
        self.setTextViewStyle()
        self.setMemoDetailViewControllerNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        self.textView.setPosition(
            top: view.safeAreaLayoutGuide.topAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor,
            trailing: view.safeAreaLayoutGuide.trailingAnchor)
    }
}

extension MemoDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let current = Date().timeIntervalSince1970
        let today = Date(timeIntervalSince1970: current)
        guard let currentIndexPath = holder?.indexPath,
              let tableView = holder?.tableView else {
            return
        }
        
        let currentMemoData = MemoDataManager.memos[currentIndexPath.row]
        let textViewTitleAndBody = textView.text.seperateTitleAndBody()
        self.saveCurrentChange(currentMemoData, textViewTitleAndBody, today)
        self.fetchCoreDataItems(context, tableView)
    }
    
    private func saveCurrentChange(_ currentMemoData: Memo, _ textViewTitleAndBody: (title: String?, body: String), _ today: Date) {
        do {
            currentMemoData.title = textViewTitleAndBody.title
            currentMemoData.body = textViewTitleAndBody.body
            currentMemoData.lastModifiedDate = today
            try self.context.save()
        } catch {
            print(CoreDataError.saveError.localizedDescription)
        }
    }
}

extension MemoDetailViewController {
    func configure(_ holder: TextViewRelatedDataHolder) {
        self.holder = holder
        self.updateTextViewText()
    }
    
    private func updateTextViewText() {
        self.textView.text =
            self.holder?.textViewText
    }
    
    private func setTextViewStyle() {
        self.textView.textAlignment = .natural
        self.textView.adjustsFontForContentSizeCategory = true
        self.textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    private func setMemoDetailViewControllerNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(didTapSeeMoreButton))
    }
    
    // MARK:- SeeMoreButton method
    @objc func didTapSeeMoreButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteActions = UIAlertAction(title: SelectOptions.delete.literal, style: .destructive, handler: { [weak self] action in
            guard let `self` = self else {
                return
            }
            self.presentDeleteAlert(self)
        })
        
        let shareAction = UIAlertAction(title: SelectOptions.share.literal, style: .default, handler: { action in
        })
        
        let cancleAction = UIAlertAction(title: SelectOptions.cancle.literal, style: .cancel, handler: { action in
        })
        
        alert.addAction(shareAction)
        alert.addAction(deleteActions)
        alert.addAction(cancleAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentDeleteAlert(_ self: MemoDetailViewController) {
        let deletAlert = UIAlertController(title: "진짜요?",
                                           message: "정말로 삭제하시겠어요?",
                                           preferredStyle: .alert)
        let deleteAlertConfirmAction = UIAlertAction(title: "삭제", style: .destructive) { action in
            let targetObject = MemoDataManager.memos[self.holder?.indexPath.row ?? .zero]
            self.deleteSaveFetchData(self.context,
                                     targetObject,
                                     self.holder?.tableView ?? UITableView())
            self.textView.text = nil
            self.splitViewController?.show(.primary)
        }
        
        let deleteAlertCancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        deletAlert.addAction(deleteAlertCancelAction)
        deletAlert.addAction(deleteAlertConfirmAction)
        self.present(deletAlert, animated: true, completion: nil)
    }
}
