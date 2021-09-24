*# 리드미 - 수정중

# 📝 동기화 메모장 리드미 
1. 개인프로젝트로 진행
2. grounds rules
    -  스크럼 
3. 커밋규칙 

### 키워드 
- `Dependency Manager`(SwiftLint, CocoaPods, SPM, 카르타고)
- `Compact&Regular Size`
- `SplitViewController`
- `CoreData`
- `Dynamic Type`
- `Accessibility`
- `iPad and iPhone Traits`
- `Data Transfer between ViewControllers`
- `Singleton`
- `Dependency Injection`


## 구현 기능 및 코드 
### 1. CRUD (Use Core Data)
- CRUD에 참여하는 객체와 이벤트에 따른 정보의 흐름 
    | ReadUpdate | CreateDelete |
    | -------- | -------- |
    | ![](https://i.imgur.com/14qDj9j.png)| ![](https://i.imgur.com/MBuZtz4.png)|

    <details>
    <summary>코어데이터에 관하여</summary>
    <div markdown="1">       

    |<img src = "https://i.imgur.com/1dQp1K0.png" width = 500, height = 500 >|
    | -------- |
    | [Reference](https://cocoacasts.com/what-is-the-core-data-stack)     |

    - Core data Stack
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

    - Persistent Container
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

    - 초기화 순서


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
    <summary>리팩토링 전 코드</summary>
    <div markdown="1">  
    
    - `MemoDataManager`라는 타입을 만들어서 model object Context 를 배열로 관리하도록 하였다.  
    
    ```swift
    //MemoDataManager.swift
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
        protocol CoreDataAccessible {
            func fetchCoreDataItems( context: NSManagedObjectContext,  tableview: UITableView)
            func saveCoreData( context: NSManagedObjectContext)
            func deleteCoreData( context: NSManagedObjectContext,  deletedObject: NSManagedObject)
        }

        extension CoreDataAccessible {
            func fetchCoreDataItems( context: NSManagedObjectContext,  tableview: UITableView) {
                do {
                    MemoDataManager.memos = try context.fetch(Memo.fetchRequest())
                    DispatchQueue.main.async {
                        tableview.reloadData()
                    }
                } catch {
                    print(CoreDataError.fetchError.localizedDescription)
                }
            }

            func saveCoreData( context: NSManagedObjectContext) {
                do {
                    try context.save()
                } catch {
                    print(CoreDataError.saveError.localizedDescription)
                }
            }

            func deleteCoreData( context: NSManagedObjectContext,  deletedObject: NSManagedObject) {
                context.delete(deletedObject)
            }

            func deleteSaveFetchData( context: NSManagedObjectContext,  deletedObject: Memo,  tableView: UITableView) {
                deleteCoreData(context, deletedObject)
                saveCoreData(context)
                fetchCoreDataItems(context, tableView)
            }
        }
    ```
    </div>
    </details>

- 리팩토링 후 코드(Trouble Shooting에 리팩토리 과정에 대해 자세히 기재하였다)
    <details>
    <summary>리팩토링 후 코드</summary>
    <div markdown="1">  

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

                func deletMemo( deletedMemoIndex: Int, completionHandler: @escaping () -> ()) {
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
            ```
    </div>
    </details>

### 2. Split View Controller를 통해 아이폰, 아이패드의 Traits에 따른 View의  
- 만약 아이폰, 아이패드 두가지 기기에서 동시에 제품이 사용되는 경우 중점을 두어야 하는 부분은 무엇일까? -> `Traits`, `UI/UX`
    - `Traits` : `Application`이 실행 되는 환경
        - `LayoutTraits` : SizeClass, Dynamic Type, Layout Direction
        - `Appearance Trits` : Display Gamut, 3D Touch, Dark/Light Mode
    - UI/UX란? `UI를 통해 제품이 제공하고자 하는 UX를 만들어 나가는 것`
        - UI : User Interface, 사용자가 product와 interact하는 환경 및 요소 
            - 예를들어 사용자의 touch, dragging, swipe 등
            > User experience is determined by how easy or difficult it is to interact with the user interface elements that the UI designers have created.
        - UX : User Experence, 사용자가 제품 혹은 서비스를 이용하면서 느끼는 경험
    ([참고영상 : These Are The 5 Big Differences Between UX And UI Design](https://careerfoundry.com/en/blog/ux-design/5-big-differences-between-ux-and-ui-design/))

- 현 프로젝트에선 `LayoutTraits`에 중심을 두었다. 
    - `SplitViewController`를 이용해서 SizeClass, 기기의 방향 등의 Layout Traits가 달라질 때 마다 레이아웃, 화면에 보여지는 형식 등이 결정되도록 구현했다.
        - 이유 : `SplitViewController`는 컨텐츠 계층을 보여주는 가장 최상위 레벨로서 2~3개의 컬럼을 가지고 있으며 상위 컬럼이 변경되는 경우 그 계층에 속한 객체들도 같이 영향을 받기 때문에 [(SplitView H.I.G)](https://www.notion.so/yagomacademy/Step1-3f8c5dac6d254331a7009bfed5aeb32e#a64d226188de4dd58ea279d7ba0ddcad)
    <details>
    <summary>리팩토링 전 코드</summary>
    <div markdown="1"> 

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
            func splitViewController( svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
                    return .primary
            }

            func splitViewController( svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
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
    </div>
    </details>
    
    - `final` 키워드 붙인 이유 : Dynamic Dispatch대신 static Dispatch가 진행되어 run time 시에 더 빠른 속도로 실행하기 위하여 
    - `presentsWithGesture`를 false로 한 이유 : 기능 명세서에서 `secondary` 컬럼이 Regular Size width일 땐 `primary`컬럼과 같이 화면에 동시에 보여야해서 `prefferedDisplayMode`를 `oneBesideSecondary`로 할당하였다. 하지만 해당 메소드가 true인 경우 스플릿 뷰의 `display` 모드를 `automatic`으로 변경하기 때문에 false로 할당하였다. 

- 리팩토링 후 코드 

    <br>
### 3. Implement UI Element Programmatically 
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

    <br>
### 4. Dependency Manager

- SPM을 이용해 SwiftLint추가하려 했으나 아직 SPM에서 지원하지 않았다. 그래서 CocoaPod으로 시도하였다. 
    ```swift
    // 추가한 SwiftLint Rules
    disabledrules:
    - linelength
    - trailingwhitespace
    - commentspacing
    - mark
    - colon
    - unusedclosureparameter
    ```
- 아래는 의존성 관리 도구의 종류와 각각의 특징이다.  
    <details>
    <summary>의존성 관리도구</summary>
    <div markdown="1">     
    1. 의존성(dependency)라는 것은 외부의 독립적인 프로그램 모듈(라이브러리, 파일 혹은 여러개의 파일, 폴더, 특정작업이 가능한 패키지 등)을 의미하는 것. 그렇다면 의존성 관리도구라는 것은 이러한 것들을 관리하는 도구를 의미 
    2. Swift에선 Swift Package Manager(SPM)라는 의존성 관리도구를 제공 
    3. 의존성 관리도구를 사용하는 이유
        i. 개발 환경에 알맞은 버전으로 의존성을 관리
        ii. 가장 최신 것으로 일괄 업데이트 가능 

    4. SPM 외의 의존성 관리도구와 특징
        1. `Cocoa pod` 
        - 빌드할 때마다 패키지를 같이 빌드하기 때문에 길어짐 

            <장점>

            - 대부분의 라이브러리가 코코아팟을 지원한다 (가장 오래되어서) 
            - 중앙화 → `Specs` 라는 레포지토리에 package를 모두 모아놓고 데이터를 제공한다. 그래서 사이트에서 검색도 가능!
            - 의존성의 의존성까지 자동으로 관리해준다.
            <단점>
            - 클린빌드하면 다 날라감
            - 빌드 할 때 시간이 오래걸림 → 팟 라이브러리가 같이 빌드되기 때문이다
            - 워크스페이스를 이용
            - 프로젝트 구성의 직접적 권한이 존재하지 않음 (내부적으로 어떻게 동작하는지 알 수 없음)
            [출처](https://ichi.pro/ko/carthage-ttoneun-cocoapods-geuge-jilmun-ibnida-18094389656523), [출처](https://ichi.pro/ko/carthage-ttoneun-cocoapods-geuge-jilmun-ibnida-18094389656523), [출처](https://baked-corn.tistory.com/109)
            - 팟 파일에 버전을 적지 않으면 최신버전을 가져온다


        2. `carthage`
        - 코코아팟의 단점을 보완해서 등장, 프레임워크를 추가 
        <장점>
            - 빌드속도가 빠름, 맨 처음에 프레임워크 만들 때 빌드 이미 함
             - 어떤 오픈소스를 쓰는지 보기 편함
             - 버전, 종속성 관리 

            <단점>
             - 새로운 패키지 쓸 때마다 프레임워크 추가해줘야함 

        3.`mint`
        - 
            <장점>
            - 버전에 따라 빌드가 캐싱된다
            - 같은 패키지라도 상황에 따라 버전 별로 사용할 수 있다

            <단점>
            - 내부적으로 SPM을 사용하는 의존성 관리 도구. [출처](https://yagom.net/courses/open-source-library/lessons/코코아팟-vs-카르타고-vs-스위프트-패키지-매니저-2/)

        4. `spm` : 스위프트 패키지 매니저 
        - 2017년 11월에 release 
            <장점>
            - 애플이 지원한다. 👍
            - Dynamic, Static 라이브러리를 모두 지원한다. (4.0 버전 이상)
            - 의존성의 의존성까지 자동으로 관리해준다.
            - 누구나 쉽게 어떤 의존성이 애플리케이션에 있는지 알 수 있다.
            - 스위프트 언어에 built-in 되어있어 별다른 설치가 필요없다. (`Swift 3` 이상)
            - 스위프트 언어에 built-in 되었기 때문에 Xcode Project 파일이 꼭 필요한 것이 아니므로 리눅스에서도 사용할 수 있다.
            - Package.swift 파일 이외에 수행할 설정이 없다.
            - Xcode의 GUI 환경에서 관리가 가능하다 (11.0 버전 이상)
            - 내부 코드를 확인가능하다.

            <단점>
            - SPM에서 지원하지 않는 라이브러리가 있어, 사용하고자 하는 라이브러리의 지원 여부 확인 필수
            - 탈중앙화 되어있기 때문에 라이브러리를 찾는 것이 더욱 수고스러울 수 있다
            - 해결되지 않은 버그가 많다.

    5. 의존성 관리 도구 비교

    - 빌드속도: Carthage > SPM ≥ CocoaPod
    - 지원하는 라이브러리 수 : CocoaPod > SPM, Carthage

    6. 의존성 관리도구와 Git을 함께 사용할 때 주의할 점은?
    - 라이브러리 설치 파일까지 Git 레포에 올라가지 않도록 주의
    - gitignore를 작성하기 전에 지워야하는 파일을 삭제하고 리모트에 반영한 뒤 gitignore를 다시 작성

    </div>
    </details>


    <br>
### 5. Accessibility
- 글씨에 `dynamic Size`를 적용할 수 있는 코드를 관련 UI요소에 구현하여 다이나믹 사이즈가 적용되도록 하였다. 
    ```swift
        //MemoListTableViewCell.swift
         private func setLabelStyle() {
            self.setDynamicType(titleLabel, .title3)
            self.setDynamicType(dateLabel, .body)
            self.setDynamicType(bodyLabel, .caption1)
            self.titleLabel.textAlignment = .left
            self.bodyLabel.textColor = .gray
        }

        private func setDynamicType( label: UILabel,  font: UIFont.TextStyle) {
            label.adjustsFontForContentSizeCategory = true
            label.font = UIFont.preferredFont(forTextStyle: font)
        }
    ```


     <br>

### 6. Cell Swipe
- 테이블 뷰의 cell을 swipe 할 때 Delete, Share의 옵션을 가지도록 구현하였다.(share 기능은 구현하지 못하고 프로젝트가 종료되었다)
    ```swift
    extension MemoListViewController: UITableViewDelegate {
       // ....

        func tableView( tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(
                style: .destructive,
                title: SelectOptions.delete.message,
                handler: { [self] , ,  in
                    if let splitViewController = self.splitViewController as? SplitViewController {
                        let deletedMemoIndex = indexPath.row
                        splitViewController.delete(deletedMemoIndex)
                    }
                })

            let shareAction = UIContextualAction(
                style: .normal,
                title: SelectOptions.share.message,
                handler: { action, view, completionHandler in
                    print("share action구현하기 ")
                })

            let swipeActions = [deleteAction, shareAction]

            return UISwipeActionsConfiguration(actions: swipeActions)
        }
    }

    ```
    <br>
    
### 7. Alert
- `seeMore` 버튼을 클릭했을 때 3개의 선태 메뉴가 나오도록 구현하였다. (share 기능은 구현하지 못하고 프로젝트가 종료되었다)
    ```swift
    extension MemoDetailViewController {   
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
    ```
    <br><br>
    
# Trouble Shooting
### 1. 데이터 전달과정에 참여하는 객체의 Decoupling 
#### 상황 1-1. ViewCtontoller간의 데이터 전달 시 MemoListVC와 MemoDetailVC사이 `직접적인` 데이터 전달이 이루어진다.

- `해결 방향` : `SplitViewConroller`(이하 `splitVC`)에서 자신이 가지고 있는 `primary`, `secondary` column에서 일어나는 이벤트에 대한 메세지를 처리하는 방향으로 구현하였다.
     - 이유 : 애플에서 아래와 같이 `splitVC`에서 `chilVC`의 message들은 `splitVC`을 거치는 흐름으로 구현하라고 권고 하였으며 `ViewController`사이에서 직접적으로 데이터를 전달하는 것 보다 훨씬 더 Decoupled 한 구조를 가지 수 있다. 또한 협업 시 모든 뷰컨을 알고있을 필요가 줄어든다.      
        > [Message Forwarding](https://developer.apple.com/documentation/uikit/uisplitviewcontroller)
        A split view controller interposes itself between the app’s window and its child view controllers. As a result, all messages to the child view controllers must flow through the split view controller. Messages are forwarded as appropriate. For example, view appearance and disappearance messages are sent only when the corresponding child view controller actually appears onscreen.
    
    
- `리팩토링 코드`
    ```swift
    extension SplitViewController {
        func presentMemo(location: Int) {
            let memo = selectedMemo(location)
            self.detailViewController.presentMemo(memo, location)
            self.show(.secondary)
        }

        private func selectedMemo( index: Int) -> Memo {
            CoreDataManager.shared.memos[index]
        }

        func delete( memo: Int) {
            CoreDataManager.shared.deletMemo(memo) {
                self.primaryViewController.updateTableView()
            }
            self.show(.primary)
        }

        func creatNewMemo( location: Int) {
            CoreDataManager.shared.createMemo {
                self.primaryViewController.updateTableView()
            }
            let memo = CoreDataManager.shared.memos[location]
            self.detailViewController.presentMemo(memo, location)
            self.show(.secondary)
        }

        func updateMemo( memo: String,  location: Int) {
            CoreDataManager.shared.updateMemo(content: memo, location: location) {
                self.primaryViewController.updateTableView()
            }
        }
    }
    ```

    ```swift
    //TableView가 있는 ViewController 
    extension MemoListViewController: UITableViewDelegate {
        func tableView( tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let memoIndex = indexPath.row
            if let splitViewController = self.splitViewController as? SplitViewController {
                splitViewController.presentMemo(location: memoIndex)
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        //.. 
    }
        
    //TextView가 있는 ViewController
    extension MemoDetailViewController: UITextViewDelegate {
        func textViewDidChange( textView: UITextView) {
            let changedMemo = self.textView.text ?? placeHolder
            if let splitViewController = self.splitViewController as? SplitViewController {
                splitViewController.updateMemo(changedMemo, self.memoIndex)
            }
        }
        //..
    }

    ```

#### 상황 1-2. 데이터 전달 과정에서 `MemoListVC`, `MemoDetailVC`가 `tableView`, `indexPath`와 연관 및 의존관계를 형성하고 있다. 또한 CoreData를 여러 ViewController에서 접근하고 있어서 thread safe하지 않은 CoreData의 특성으로 인해 오류가 생기고 있다. 
- 오류 메세지 
    <img src = "https://i.imgur.com/mslyGTf.png" width = 400>

- `해결방향` : 코어데이터를 `Singleton` 객체로 만들어서 `splitVC`에서만 데이터 접근하도록 하였다. 
- `리팩토링 코드`     
    ```swift
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

        func updateMemo(content: String, location: Int, completionHandler: @escaping () -> ()) {
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

        func deletMemo( deletedMemoIndex: Int, completionHandler: @escaping () -> ()) {
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

    ```
#### ♦️ 리팩토링 전 후 ♦️                           
| 리팩토링 전 | 리팩토링 후 |
| -------- | -------- |
| ![](https://i.imgur.com/GS7eZGY.png)| ![](https://i.imgur.com/Sd4QE4Z.png)|


<br>
    
### 2. cell 스택뷰의 경고창

#### 상황 : 기기를 회전할 때 스택뷰의 레이아웃 경고가 생기고 바디를 입력할 때마다 레이아웃이 변경됨 
| 경고 메세지  | Debugging Consol |
| -------- | -------- |
![](https://i.imgur.com/OW7LZHk.png)| ![](https://i.imgur.com/cTVFlHu.png)| 
**textView에서 body에 해당하는 부분 입력 시 왼쪽 테이블뷰 cell의 레이아웃이 변경**
![](https://i.imgur.com/N9AnYrh.gif) |


- `해결` : 스택뷰가 `topAnchor`로 가지고 있던 `titleLabel`의 `bottomAnchor`에 `nil`이 아닌 `contentView`의 anchor를 할당 
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
                               
        // 밑에서 설명하겠지만 Hugging, Compression priority까지 같이 구현 하였음 
        ```
- `결론` : cell 내부 UI요소들의 오토레이아웃이 잘 구현되지 않아서 생겼던 문제. 다양한 변화에 대응할 수 있는 autolayout을 구현해야 UI요소와 그 내부 컨텐츠들이 화면에 나타날 수 있다. 
    <br>
    
### 3. 다이나믹 타입을 적용해서 글자크기를 증가했을 때 cell의 레이아웃이 깨지는 현상
 - #### 상황 : Textview에는 잘 적용이 되는데 cell에는 잘 적용이 안됨
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
    - 객체와 객체사이의 수직 간격이 이전에는 없었기 때문에 간격을 넓힘으로서 위 아래 레이블이 완전히 겹치는 문제는 해결되었다. 
    - `Dynamic Size`가 커치면서 `stackView`에 넣은 `dateLabel`, `BodyLabel`이 잘 안보이는 부분은 무엇때문일까?
    -> cell의 높이가 동적으로 변하도록 `시도1`의 코드를 추가했음에도 글씨크기 변경해 주었을 때 cell의 높이가 변경되지 않으므로 cell의 높이에도 어느정도의 제한이 있는 것으로 관찰된다. 
        ```swift
        //시도1
        tableView.rowHeight = UITableView.automaticDimension
        ```    
- 지금처럼 간격을 지정하는 방법이 아닌 사이즈에 따라 알아서 높이가 지정되도록 하는 방법은 무엇이 있을까?

    <br>
### 4. StackView의 `leadingAnchor` 에 관하여
- #### 상황 : 아래처럼 leadingAnchor를 safeAreaLayoutGuide의  leadingAnchor로 변경했더니 잘 구현됨

    | 코드 수정 전| 코드 수정 후|
    | -------- | -------- |
    | <img src = "https://i.imgur.com/pJCXMqq.png" height = 500, width = 600 >     | <img src = "https://i.imgur.com/zNlmOqg.png" height = 500, width = 600 >     |

 
    - 수정전 코드

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

    - 수정 후 코드 : leading 부분만 safeAreaLayoutGuide로 수정
    ```swift
    dateAndSubStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
    ```
- `이유` 
    1. 여러가지 이유가 있겠지만 아래와 같은 이유로 처음에 레이아웃이 잘 잡히지 않은 듯 하다.     
        - `bodyLabel`의 `compressionResistence`가 `dateLabel`과 동일거나 높아서 `bodyLabel`의 내부 컨텐츠의 내용이 많아지자 `dateLabel`이 축소됨. 
        - 공식문서에 보면 아래와 같이 나와있다. 
            > Your app’s content occupies most of the cell’s bounds, but the cell may adjust that space to make room for other content. 

            즉 cell은 내부의content를 잘 표시하기 위해 cell의 bounds를 적절하게 변경할 수 있다. 따라서 leading anchor를 contentView로 정했을 때 추가적인 정보가 없다면 cell의 입장에선 어떤 것을 우선순위로 제한된 cell 내부에 보여야할지 모르게 된다. 
        
    - `실험` : contentView로 레이아웃을 잡을 때 아래와 같이 구현하면 같은 결과가 나온다. 
    ```swift
     dateAndBodyStackView.setPosition(
        top: titleLabel.bottomAnchor,
        bottom: contentView.bottomAnchor,
        leading: contentView.leadingAnchor,
        trailing: contentView.trailingAnchor
        )
                            
    dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    ```
    <br>
### 5. 회전하면 테이블뷰의 일부가 잘 보이지 않는다. 
- iPad pro / iphone11 에서의 모습 
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
     - 결과
    <img src = "https://i.imgur.com/2jEswTY.gif" height = 200>
    
- `시도3` : tableView의 레이아웃이 잘못되었다고 판단하고 다시 tableView의 레이아웃을 리팩토링 -> 테이블뷰가 전체 화면을 다 채움 
    ```swift
    tableView.frame = view.bounds
    ```
- `결론` : tableView의 레이아웃이 잘 잡히지 않아 생겼던 문제. `cellLayoutMarginsFollowReadableWidth` 속성은 custom cell에선 영향이 없다. 
