# 리드미 - 수정중
## 구현 기능 및 코드 

### Implement UI Element Programmatically 
- UIView 클래스에서 extension을 통해 view의 위치를 `setPosition` 메소드에 알맞은 인자를 넣어서 계산하도록 구현
```swift
extension UIView {
    func setPosition(top: NSLayoutYAxisAnchor?,
                     topConstant: CGFloat = .zero,
                     bottom: NSLayoutYAxisAnchor?,
                     bottomConstant: CGFloat = .zero,
                     leading: NSLayoutXAxisAnchor?,
                     leadingConstant: CGFloat = .zero,
                     trailing: NSLayoutXAxisAnchor?,
                     trailingConstant: CGFloat = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        top.flatMap {
            topAnchor.constraint(equalTo: $0, constant: topConstant).isActive = true
        }
        
        bottom.flatMap {
            bottomAnchor.constraint(equalTo: $0, constant: bottomConstant).isActive = true
        }
        
        leading.flatMap {
            leadingAnchor.constraint(equalTo: $0, constant: leadingConstant).isActive = true
        }
        
        trailing.flatMap {
            trailingAnchor.constraint(equalTo: $0, constant: trailingConstant).isActive = true }
    }
}
```

### Use `Core Data` for `CRUD`
<details>
<summary>코어데이터에 관하여</summary>
<div markdown="1">       

|<img src = "https://i.imgur.com/1dQp1K0.png" width = 500, height = 500 >|
| -------- |
| [Reference](https://cocoacasts.com/what-is-the-core-data-stack)     |

- **Core data Stack**
    = 영구저장소 + 오브젝트 모델 + 영구저장소 코디네이터 + 메니지드 오브젝트 컨텍스트 

    - 대부분은 컨텍스트가 제공하는 API 로 기능을 구현
        - hasChanges, save, fetch 등등
    - 컨텍스트를 통해 필요한 정보를 저장 → 영구저장소 Coordinator 가 컨테이너와 모델 사이를 중계 , 오브젝트 모델을 통해 구조 파악 → 영구저장소에 알아서 저장

    - `persisTent Store`
        - 4가지, 기본은 SQLite(non aomic store)
        - xml, binary는거의 안 쓰고 In-Memory는 캐쉬 할 때 사용하기도 한다 

    - `Object Model`
        - `NSManagedObjectModel` 객체 이용
        - 코드를 통해 직접 구성할 수도 있지만 xCode통해 많이 구현 함

    - `Persistent Store Coordinator`
        - `NSPersistentStoreCoordinator` 객체로 만든다
        - 컨테이너와 모델 사이 저장을 할 수 있도록 중계
        - 모델과 컨텍스트의 참조를 유지시켜준다.
        - 영구저장소를 관리한다.

    - `Managed Object Context`
        - `NSManagedObjectContext` 객체로 만든다. 
        - 코어데이터에서 데이터 만들고 컨텍스트에서 저장을 요청(임시저장)
        - 여기에 저장안하고 끄면 모두 사라짐
        - 영구저장소에서 데이터 가져와서 처리하는 곳도 컨텍스트. 그 땐 복사본을 가져온다
        - 컨텍스트의 데이터를 수정해도 원본은 수정되지 않는다.

- **Persistent Container**
    - 코어데이터 스택을 하나의 개념으로 추상화 한 것 
    - 실제 코드
    - 앱에 기본적으로 구현되는 것
        ```swift
        // MARK: - Core Data stack
            lazy var persistentContainer: NSPersistentContainer = {
                let container = NSPersistentContainer(name: "CoreDataTutorial")
                container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                    if let error = error as NSError? {
                        fatalError("Unresolved error \(error), \(error.userInfo)")
                    }
                })
                return container
            }()

            // MARK: - Core Data Saving support

            func saveContext () {
                let context = persistentContainer.viewContext
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
        ```

- **초기화 순서**


| <img src = "https://i.imgur.com/G4IVRag.png" height = 200 width = 200> |
| -------- |
|1 : 앱 번들에서 데이터모델 로드 : xcode이용해서 추가하는 entitiy, attribute그건가? | 
2 : 코디네이터를 초기화함. 
3 : 코디네이터가 모델이랑 영구저장소가 compatible한지 확인한다. 이것이 코디네이터가 두 객체를 참조하고 있는 이유. 
4 : 컨텍스트는 코디네이터에 대한 참조 값을 가져야 한다.(코디네이터, 모델이 먼저 초기화 되는 이유)| 

- 모든 컨텍스트 객체가 코디네이터에 대한 참조값을 가지는 것은 아니다.

</div>
</details>

<details>
<summary>리팩토링 전</summary>
<div markdown="1">  
- `MemoDataManager`라는 타입을 만들어서 model object Context 를 배열로 관리하도록 하였다.  
    ```swift
    //MemoDataManager.swift
    //MARK:- Hold Memo Array and persistentConatiner's viewContext
    final class MemoDataManager {
        static var memos: [Memo] = { () -> [Memo] in
            do {
                let test = try context.fetch(Memo.fetchRequest()) as [Memo]
                return test
            } catch {
                return []
            }
        }()
    
        static let context: NSManagedObjectContext = { () -> NSManagedObjectContext in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            }
            let context = appDelegate.persistentContainer.viewContext
            return context
        }()
    }

    ```
- CoreDataAccessible 프로토콜을 통해 코어데이터의 context의 여러 메소드를 캡슐화 하였다.  
    ```swift
    //CoreDataAccessible.swift
    //MARK:- Provide Method related to CoreData saving, fetching, deleting
    protocol CoreDataAccessible {
        func fetchCoreDataItems(_ context: NSManagedObjectContext, _ tableview: UITableView)
        func saveCoreData(_ context: NSManagedObjectContext)
        func deleteCoreData(_ context: NSManagedObjectContext, _ deletedObject: NSManagedObject)
    }

    extension CoreDataAccessible {
        func fetchCoreDataItems(_ context: NSManagedObjectContext, _ tableview: UITableView) {
            do {
                MemoDataManager.memos = try context.fetch(Memo.fetchRequest())
                DispatchQueue.main.async {
                    tableview.reloadData()
                }
            } catch {
                print(CoreDataError.fetchError.localizedDescription)
            }
        }

        func saveCoreData(_ context: NSManagedObjectContext) {
            do {
                try context.save()
            } catch {
                print(CoreDataError.saveError.localizedDescription)
            }
        }

        func deleteCoreData(_ context: NSManagedObjectContext, _ deletedObject: NSManagedObject) {
            context.delete(deletedObject)
        }

        func deleteSaveFetchData(_ context: NSManagedObjectContext, _ deletedObject: Memo, _ tableView: UITableView) {
            deleteCoreData(context, deletedObject)
            saveCoreData(context)
            fetchCoreDataItems(context, tableView)
        }
    }
    ```
</div>
</details>


### Accessibility
- dynamic Size를 적용할 수 있는 코드를 text를 표현하는 모든 UI요소에 구현하여 다이나믹 사이즈가 잘 적용되도록 하였다. 
    ```swift
        //MemoListTableViewCell.swift
         private func setLabelStyle() {
            self.setDynamicType(titleLabel, .title3)
            self.setDynamicType(dateLabel, .body)
            self.setDynamicType(bodyLabel, .caption1)
            self.titleLabel.textAlignment = .left
            self.bodyLabel.textColor = .gray
        }

        private func setDynamicType(_ label: UILabel, _ font: UIFont.TextStyle) {
            label.adjustsFontForContentSizeCategory = true
            label.font = UIFont.preferredFont(forTextStyle: font)
        }
       ```

### `Split View Controller`를 통해 아이폰과 아이패드에서의 Traits에 알맞게 구현하기??
- 만약 아이폰, 아이패드 두가지 기기에서 동시에 제품이 사용되는 경우 중점을 두어야 하는 부분은 무엇일까? -> `Traits`, `UI/UX`
    - Traits란? Application이 실행 되는 환경
        - LayoutTraits : SizeClass, Dynamic Type, Layout Direction
        - Appearance Trits : Display Gamut, 3D Touch, Dark/Light Mode
    - UI/UX란? `UI를 통해 제품이 제공하고자 하는 UX를 만들어 나가는 것`
        - UI : User Interface, 사용자가 product와 interact하는 환경 및 요소 
            - 예를들어 사용자의 touch, dragging, swipe 등
            > User experience is determined by how easy or difficult it is to interact with the user interface elements that the UI designers have created.
        - UX : User Experence, 사용자가 제품 혹은 서비스를 이용하면서 느끼는 경험
    ([참고영상 : These Are The 5 Big Differences Between UX And UI Design](https://careerfoundry.com/en/blog/ux-design/5-big-differences-between-ux-and-ui-design/))

- 현 프로젝트에선 `LayoutTraits`에 중심을 두었다. 
    - `SplitViewController`를 이용해서 자동으로 `autoLayout`이 적용되는 Layout Traits를 만들고자 했다
        - SplitViewController는 컨텐츠 계층을 보여주는 가장 최상위 레벨로서 2~3개의 컬럼을 가지고 있으며 상위 컬럼이 변경되는 경우 그 계층에 속한 객체들도 같이 영향을 받는다. [(SplitView H.I.G)](https://www.notion.so/yagomacademy/Step1-3f8c5dac6d254331a7009bfed5aeb32e#a64d226188de4dd58ea279d7ba0ddcad)
    - 코드 
    ```swift
    final class SplitViewController: UISplitViewController {
        private let detailVC = MemoDetailViewController()
        private let primaryVC = MemoListViewController()

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
            self.setViewController(primaryVC, for: .primary)
            self.setViewController(detailVC, for: .secondary)
        }
    }
    ```
    - `final` 키워드 붙인 이유 : Dynamic Dispatch대신 static Dispatch가 진행되어 run time 시에 더 빠른 속도로 실행하기 위하여 
    - `presentsWithGesture`를 false로 한 이유 : 기능 명세서에서 `secondary` 컬럼이 Regular Size width일 땐 `primary`컬럼과 같이 화면에 동시에 보여야해서 `prefferedDisplayMode`를 `oneBesideSecondary`로 할당하였다. 하지만 해당 메소드가 true인 경우 스플릿 뷰의 `display` 모드를 `automatic`으로 변경하기 때문에 false로 할당하였다. 
 
### Update Date 
1. 텍스트뷰의 내용이 변경된 날짜를 업데이트 해주기  
    - 기존 코드 
    ```swift
    extension DateFormatter {
        func updateLastModifiedDate(_ lastModifiedDateInt: Int?) -> String {
            let customDateFormatter = customDateFormatter()
            let date = Date(timeIntervalSince1970: Double(lastModifiedDateInt ?? .zero))
            let dateString = customDateFormatter.string(from: date)
        
            return dateString
        }
    
        private func customDateFormatter() -> DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        
            return formatter
        }
    }
    ```
    
    ```swift
    // 해당 날짜를 Int타입으로 변경 후 CoreData에 저장
    extension Date {
        func makeCurrentDateInt64Data() -> Int64 {
            let timeInterval = self.timeIntervalSince1970
            let currentDateInt64Type = Int64(timeInterval)
            return currentDateInt64Type
        }
    }
    ```
    - 리팩토링 코드 
        - 코어데이터 attribute의 타입을 Date로 변경하기 
        - cell에서 content를 표시하는 부분에서 아래 `updateLastModifiedDate` 메소드를 이용해 String으로 변경하기 
        ```swift
        extension DateFormatter {
            func updateLastModifiedDate(_ lastModifiedDate: Date) -> String {
            let customDateFormatter = customDateFormatter()
            let dateString = customDateFormatter.string(from: lastModifiedDate)
        
            return dateString
            }
    
            private func customDateFormatter() -> DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")

            return formatter
            }
        }

        ```
 # Trouble Shooting
 
 ### 오토레이아웃
 #### cell 스택뷰의 경고창
- 상황 : 기기를 회전할 때 스택뷰의 레이아웃 경고가 생김
        
    | 경고 메세지  | Debugging Consol |
    | -------- | -------- | 
    ![](https://i.imgur.com/OW7LZHk.png)| ![](https://i.imgur.com/cTVFlHu.png)|

- `해결` : 스택뷰가 topAnchor로 가지고 있던 titleLabel의 bottomAnchor에 nil이 아닌 contentView의 anchor를 할당 
    - 이전 코드
        ```swift
        //MainTableViewCell
         titleLabel.setPosition(top: nil,
                               bottom: nil,
                               leading: safeAreaLayoutGuide.leadingAnchor,
                               leadingConstant: 10,
                               trailing: contentView.trailingAnchor)
        ```
    - 수정 후 코드
        ```swift
        //MainTableViewCell
        titleLabel.setPosition(top: contentView.topAnchor,
                               bottom: contentView.bottomAnchor, bottomConstant: -20,
                               leading: contentView.leadingAnchor,
                               trailing: contentView.trailingAnchor)
        ```
- `결론` : cell 내부 UI요소들의 오토레이아웃이 잘 구현되지 않아서 생겼던 문제. 다양한 변화에 대응할 수 있는 autolayout을 구현해야 UI요소와 그 내부 컨텐츠들이 화면에 나타날 수 있다. 

#### 다이나믹 타입을 적용했을 때 cell에는 적용이 안되는 부분
 - 상황 : Textview에는 잘 적용이 되는데 cell에는 잘 적용이 안됨
![](https://i.imgur.com/s8qGglW.gif)

- `시도1`. cell의 높이가 dynamic하게 resizing 되지 않아 겹치는 것일 수 있기 때문에 ` PrimaryViewController`에 아래 코드 추가 
-> 변화없음 
   ```swift
    tableView.rowHeight = UITableView.automaticDimension
   ```

- `시도2`. top과 bottom anchor 를 지정 -> 이전보다 나아짐
     ```swift
     private func setupTitleLabelLayout() {
        // dateLabel, bodyLabel초기화 및 view에 추가
        //...
        
        let height = 30
        dateAndBodyStackView.setPosition(top: contentView.topAnchor, topConstant: height,
                                         bottom: contentView.bottomAnchor,
                                         leading: contentView.leadingAnchor,
                                         trailing: contentView.trailingAnchor)
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
     ```
     ![](https://i.imgur.com/bV4f2iX.gif)

- `결론`
    - 객체와 객체사이의 간격이 이전에는 0이 었기 때문에 간격을 넓힘으로서 위 아래 레이블이 완전히 겹치는 문제는 해결되었다. 
    - Dynamic Size가 커치면서 stackView에 넣은 dateLabel, BodyLabel이 잘 안보이는 부분은 무엇때문일까?
    -> cell의 높이가 동적으로 변하도록 `시도1`의 코드를 추가했음에도 글씨크기 변경해 주었을 때 cell의 높이가 변경되지 않으므로 cell의 높이에도 어느정도의 제한이 있는 것으로 관찰된다. 
        ```swift
        //시도1
        tableView.rowHeight = UITableView.automaticDimension
        ```    
- 지금처럼 간격을 지정하는 방법이 아닌 사이즈에 따라 알아서 높이가 지정되도록 하는 방법은 무엇이 있을까?


#### StackView의 `leadingAnchor` 에 관하여
- 아래처럼 leadingAnchor를 safeAreaLayoutGuide의  leadingAnchor로 변경했는데 잘 잡힘

    | 코드 수정 전 | 코드 수정 후 |
    | -------- | -------- |
    | <img src = "https://i.imgur.com/pJCXMqq.png" height = 300, width = 900 >| <img src = "https://i.imgur.com/zNlmOqg.png" height = 300, width = 900 > |

     (safeArea 와 view를 구분해 주기 위해 view의 backgroundColor를 빨간색으로 설정)
 
    **수정 전 코드**

    ```swift
    private func makeHorizontalStackVeiw() {
            dateAndSubStackView = UIStackView(arrangedSubviews: [self.dateLabel, self.subTitleLabel])
            contentView.addSubview(dateAndSubStackView)
            dateAndSubStackView.translatesAutoresizingMaskIntoConstraints = false
            dateAndSubStackView.axis = .horizontal
            dateAndSubStackView.distribution = .equalCentering

            dateAndSubStackView.spacing = 40
            dateAndSubStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            dateAndSubStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            dateAndSubStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        }
    ```

    **수정 후 코드** : leading 부분만 safeAreaLayoutGuide로 수정 해주었습니다. 
    ```swift
    dateAndSubStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
    ```
- 여러가지 이유가 있겠지만 아래와 같은 이유로 처음에 레이아웃이 잘 잡히지 않은 듯 하다.     
    - 1) bodyLabel의 compressionResistence가 dateLabel과 동일거나 높아서 bodyLabel의 내부 컨텐츠의 내용이 많아지자 dateLabel이 축소됨. 아래의 코드를 구현하면 정상적으로 dateLable, bodyLabel의 컨텐츠가 출력된다. 
        ```swift
        bodyLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) 
        ```
- safeAreaLayout으로 leading anchor를 설정하면 stack뷰가 잘 나왔던 이유
    - 공식문서에 보면 아래와 같이 나와있다. 
    > Your app’s content occupies most of the cell’s bounds, but the cell may adjust that space to make room for other content. 

    즉 cell은 내부의content를 잘 표시하기 위해 cell의 bounds를 적절하게 변경할 수 있다. 따라서 (예를들어 스택 내부 label들의 compressionResistence의 값을 적절하게 변경하기 등)leading anchor를 contentView로 정했을 때 cell의 입장에선 어떤 것을 우선순위로 제한된 cell 내부에 보여야할지 모르게 된다. 
    수정 전 코드 
    ```swift
     dateAndBodyStackView.setPosition(
        top: titleLabel.bottomAnchor,
        bottom: contentView.bottomAnchor,
        leading: contentView.leadingAnchor,
        trailing: contentView.trailingAnchor
        )
    ```
    수정 후 코드 
    ```swift                           
    //아래 코드 추가  
    dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    ```

#### 회전하면 테이블뷰의 일부가 잘 보이지 않는 문제 
- 상황
    | ![](https://i.imgur.com/Rpjw2lu.gif) | ![](https://i.imgur.com/rnXpAv5.gif) | 
    | -------- | -------- |
- `시도1` :  `cellLayoutMarginsFollowReadableWidth` 를 true로 설정해서 그런것이라고 판단하고 원래의 default 로 변경 -> 변화없음 

    - 이유 : 위의 속성은 cell이 default 스타일 중 하나일때만 자동으로 여백이 조정되도록 하는 속성이기 때문

- `시도2` : tablView의 레이아웃을 safeAreaLayoutGuide 를 기준으로 리팩토링 

    ```swift
    // 여기서 setAcnchor는 추후 setPosition으로 reNaming
    tableView.setAnchor(top: view.safeAreaLayoutGuide.topAnchor, 
                        bottom: view.safeAreaLayoutGuide.bottomAnchor, 
                        leading: view.safeAreaLayoutGuide.leadingAnchor, 
                        trailing: view.safeAreaLayoutGuide.trailingAnchor)
    ```
      
    <img src = "https://i.imgur.com/2jEswTY.gif" height = 200>
    
- `시도3` : tableView의 레이아웃이 잘못되었다고 판단하고 다시 tableView의 레이아웃을 리팩토링 -> 테이블뷰가 전체 화면을 다 채움 
    ```swift
    tableView.frame = view.bounds
    ```
- `결론` : tableView의 레이아웃이 잘 잡히지 않아 생겼던 문제. `cellLayoutMarginsFollowReadableWidth` 속성은 custom cell에선 영향이 없다. 










