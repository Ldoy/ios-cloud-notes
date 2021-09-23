//
//  DetailViewController.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/05.
//

import UIKit
import CoreData

final class MemoDetailViewController: UIViewController {
    private lazy var textView = UITextView()
    private var memoIndex: Int = .zero
    private let placeHolder = ""
    
    func presentMemo(_ memo: Memo, _ location: Int) {
        let title = memo.title ?? placeHolder
        let body = memo.body ?? placeHolder
        self.textView.text = title + body
        self.memoIndex = location
    }
    
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
        let changedMemo = self.textView.text ?? placeHolder
        if let splitViewController = self.splitViewController as? SplitViewController {
            splitViewController.updateMemo(changedMemo, self.memoIndex)
        }
    }
}

extension MemoDetailViewController {    
    private func setTextViewStyle() {
        self.textView.textAlignment = .natural
        self.textView.adjustsFontForContentSizeCategory = true
        self.textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    private func setMemoDetailViewControllerNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(didTapSeeMoreButton))
    }
    
    @objc func didTapSeeMoreButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteActions = UIAlertAction(title: SelectOptions.delete.message, style: .destructive, handler: { [self] action in
            let deletAlert = UIAlertController(title: "진짜요?",
                                               message: "정말로 삭제하시겠어요?",
                                               preferredStyle: .alert)
            
            let deleteAlertConfirmAction = UIAlertAction(title: "삭제", style: .destructive) { action in
                if let splitViewcontroller = self.splitViewController as? SplitViewController {
                    splitViewcontroller.delete(self.memoIndex)
                    self.memoIndex -= 1
                    self.textView.text = ""
                }
            }
            
            let deleteAlertCancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            deletAlert.addAction(deleteAlertCancelAction)
            deletAlert.addAction(deleteAlertConfirmAction)
            self.present(deletAlert, animated: true, completion: nil)
        })
        
        let shareAction = UIAlertAction(title: SelectOptions.share.message, style: .default, handler: { action in
        })
        
        let cancleAction = UIAlertAction(title: SelectOptions.cancle.message, style: .cancel, handler: { action in
        })
        
        alert.addAction(shareAction)
        alert.addAction(deleteActions)
        alert.addAction(cancleAction)
        
        present(alert, animated: true, completion: nil)
    }
}
