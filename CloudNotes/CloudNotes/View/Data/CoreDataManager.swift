//
//  File.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/11.
//

import UIKit
import CoreData

//MARK:- Hold Memo Array and persistentConatiner's viewContext
final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() { }
    
    lazy var memos: [Memo] = { () -> [Memo] in
        do {
            let test = try context.fetch(Memo.fetchRequest()) as [Memo]
            return test
        } catch {
            return []
        }
    }()
    
    private let context: NSManagedObjectContext = { () -> NSManagedObjectContext in
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        let context = appDelegate.persistentContainer.viewContext
        return context
    }()
    
    func updateMemo(content: String, location: Int, completionHandler: @escaping () -> Void) {
        let titleAndBody = content.seperateTitleAndBody()
        let title = titleAndBody.title
        let body = titleAndBody.body
        let targetMemo = CoreDataManager.shared.memos[location]
        targetMemo.title = title
        targetMemo.body = body
        saveCoreData()
        fetchCoreDataItems()
        completionHandler()
    }
    
    func createMemo(completionHandler: @escaping () -> ()) {
        let newMemo = Memo(context: CoreDataManager.shared.context)
        newMemo.lastModifiedDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        self.memos.append(newMemo)
        self.saveCoreData()
        self.fetchCoreDataItems()
        completionHandler()
    }
    
    func deletMemo(_ deletedMemoIndex: Int, completionHandler: @escaping () -> ()) {
        if deletedMemoIndex < .zero {
            return
        }
        let deletedMemo = self.memos[deletedMemoIndex]
        self.context.delete(deletedMemo)
        saveCoreData()
        fetchCoreDataItems()
        completionHandler()
    }
    
    private func fetchCoreDataItems() {
        do {
            self.memos = try self.context.fetch(Memo.fetchRequest())
        } catch {
            print(CoreDataError.fetchError.localizedDescription)
        }
    }
    
    private func saveCoreData() {
        do {
            try self.context.save()
        } catch {
            print(CoreDataError.saveError.localizedDescription)
        }
    }
}
