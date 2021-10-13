# 동기화 메모장 최종 리드미 
# 목차 
- [📝 동기화 메모장](#----------)
  * [키워드](#키워드)
- [구현 기능 및 코드](#구현-기능-및-코드)
- [Trouble Shooting](#trouble-shooting)
    + [1. 데이터 전달과정에 참여하는 객체의 Decoupling](#1-데이터-전달과정에-참여하는-객체의-decoupling)
    + [2. cell 스택뷰의 경고창](#2-cell-스택뷰의-경고창)
    + [3. 다이나믹 타입을 적용해서 글자크기를 증가했을 때 cell의 레이아웃이 깨지는 현상](#3-다이나믹-타입을-적용해서-글자크기를-증가했을-때-cell의-레이아웃이-깨지는-현상)
    + [4. StackView의 leadingAnchor에 관하여](#4-stackview의-leadinganchor에-관하여)
    + [5. 회전하면 테이블뷰의 width가 줄어드는 문제](#5-회전하면-테이블뷰의-width가-줄어드는-문제)
- [고민한 부분](#고민한-부분)
- [아쉬운 부분](#아쉬운-부분)

# 📝 동기화 메모장  
1. 프로젝트 기간 : 2021.08.30 - 09.17
1. 개인프로젝트
2. grounds rules
    - 10시에 스크럼 시작 
    - 프로젝트가 중심이 아닌 학습과 이유에 초점을 맞추기
    - 의문점을 그냥 넘어가지 않기
3. 커밋규칙 
    - 브랜치 : main → 3-tacocat → step1
    - 카르마스타일
    - 메서드 및 타입단위로

## 키워드 
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
- `Swift Performance`

<br>

## 구현 기능 및 코드 

[1. CRUD (Use Core Data)](#1-crud-by-coredata) <br>
[2. Adapt LayoutTraits through SplivtViewController](#2-adapt-layouttraits-through-splivtviewcontroller) <br>
[3. Implement UI Element Programmatically](#3-implement-ui-element-programmatically) <br>
[4. Dependency Manager](#4-dependency-manager) <br>
[5. Accessibility](#5-accessibility) <br>
[6. Cell Swipe](#6-cell-swipe) <br>
[7. Alert](#7-alert) <br>

<br>

<details>
<summary> 🌟구현기능🌟 </summary>
<div markdown="1">       

### 1. CRUD by CoreData
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
    
<br>


### 2. Adapt LayoutTraits through SplivtViewController 
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
</div>
</details>

<br>

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
<br>

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

<br>

#### ♦️ 리팩토링 전 후 ♦️                           
| 리팩토링 전 | 리팩토링 후 |
| -------- | -------- |
| ![](https://i.imgur.com/GS7eZGY.png)| ![](https://i.imgur.com/Sd4QE4Z.png)|


<br>
    
### 2. cell 스택뷰의 경고창

#### 상황 : 기기를 회전할 때 스택뷰의 레이아웃 경고가 생기고 바디를 입력할 때마다 레이아웃이 변경됨 
| 경고 메세지  | Debugging Consol |
| -------- | -------- |
<img src = "https://i.imgur.com/OW7LZHk.png" width = 200, height = 300>| <img src = "https://i.imgur.com/cTVFlHu.png" width = 200, height = 300>| 
**textView에서 body에 해당하는 부분 입력 시 왼쪽 테이블뷰 cell의 레이아웃이 변경** 
<img src = "https://i.imgur.com/N9AnYrh.gif" width = 200>|


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
    <br><br>
    
### 3. 다이나믹 타입을 적용해서 글자크기를 증가했을 때 cell의 레이아웃이 깨지는 현상
 - #### 상황 : Textview에는 잘 적용이 되는데 cell에는 잘 적용이 안됨
    <img src = "https://i.imgur.com/s8qGglW.gif" width = 300>

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
     - 결과
     <img src = "https://i.imgur.com/bV4f2iX.gif" width = 300>


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
### 4. StackView의 leadingAnchor에 관하여
- #### 상황 : 아래처럼 leadingAnchor를 safeAreaLayoutGuide의  leadingAnchor로 변경했더니 잘 구현됨

    | 코드 수정 전| 코드 수정 후|
    | -------- | -------- |
    | <img src = "https://i.imgur.com/pJCXMqq.png" height = 300>     | <img src = "https://i.imgur.com/zNlmOqg.png" height = 300>     |

 
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
### 5. 회전하면 테이블뷰의 width가 줄어드는 문제 
- iPad pro / iphone11 에서의 모습 
    | <img src = "https://i.imgur.com/Rpjw2lu.gif" width = 200, height = 300> | <img src = "https://i.imgur.com/rnXpAv5.gif" height = 300> | 
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
    
- `시도3` : 테이블뷰가 전체 화면을 다 채우도록 구현
    ```swift
    tableView.frame = view.bounds
    ```
- `결론` : tableView의 레이아웃이 잘 잡히지 않아 생겼던 문제. 시도2, 시도3의 방법으로 구현하니 정상적으로 잘 나왔다. `cellLayoutMarginsFollowReadableWidth` 속성은 custom cell에선 영향이 없다. 

<br>
                
# 고민한 부분 
[1. cell에게 정보를 전달하는 방법](#1-cell에게-정보를-전달하는-방법)<br>
[2. 어떻게하면 성능을 좋게 할 수 있을까](#2-어떻게하면-성능을-좋게-할-수-있을까)<br>
[3. ViewController의 역할 최대한 분리하는 방법](#3-viewcontroller의-역할-최대한-분리하는-방법)<br>
[4. 코어데이터 저장소는 어떤 객체가 가지고 있어야 할까](#4-코어데이터-저장소는-어떤-객체가-가지고-있어야-할까)<br>
[5. TextView에서 제목과 본문을 나눠야 하는데 어떻게 나눌 수 있을까](#5-textview에서-제목과-본문을-나눠야-하는데-어떻게-나눌-수-있을까)<br>
[6. 코어데이터의 entity, attribute의 구성](#6-코어데이터의-entity-attribute의-구성)<br>
[7. MVC모델에 기반한 grouping](#7-mvc모델에-기반한-grouping)<br>
[8. lazy키워드, closure를 이용해 UI요소를 초기화 하면 좋은 부분은 어디일까](#8-lazy키워드-closure를-이용해-ui요소를-초기화-하면-좋은-부분은-어디일까)<br>
[9. `CellId`열거형](9--cellid-열거형)

<br>


<details>
<summary>🌟고민한 부분🌟</summary>
<div markdown="1">       

#### 1. cell에게 정보를 전달하는 방법 
- 아래와 같이 Holder에 담아서 전달한다. 
    - 이유 : Holder내부에서 데이터 가공 할 수 있으며 이 역할을 Holder에게 부여하므로서 각 객체의 역할을 확실히 구분할 수 있기 때문이다. 
```swift
final class CellContentDataHolder {
    let titleLabelText: String
    let dateLabelText: String
    let bodyLabelText: String

    init(title: String, date: Date, body: String) {
        let modifiedDate =  DateFormatter().updateLastModifiedDate(date)
        self.dateLabelText = "\(modifiedDate)"
        self.titleLabelText = title
        self.bodyLabelText = body
        }
    }
}
```
<br>

#### 2. 어떻게하면 성능을 좋게 할 수 있을까
1. class타입의 참조 기능만 사용하는 경우 `final` 키워드 추가 한다
    - 이유 : Dynamic Dispatch가 아닌 Static Dispatch로 메서드 디스패치의 방법을 바꿀 수 있기 때문
    - 현재 사용되는 대부분의 class타입의 객에에 final 키워드 추가 하였다. 

2. 구조체 내부에 속성의 타입이 참조타입이 많은 경우 구조체가 아닌 클래스로 바꾼다. 
    - 이유 : 구조체의 경우 copy 가 일어날 때 속성의 heat영역도 copy 되기 때문에 class로 구현했을 때보다 Reference Count 오버헤드가 발생한다. 
    - cellDataHolder객체를 struct에서 class로 변경
        ```swift
        final class CellContentDataHolder {
            let titleLabelText: String
            let dateLabelText: String
            let bodyLabelText: String

            init(title: String, date: Date, body: String) {
                let modifiedDate =  DateFormatter().updateLastModifiedDate(date)
                self.dateLabelText = "\(modifiedDate)"
                self.titleLabelText = title
                self.bodyLabelText = body
            }
        }
        ```
        <br>
#### 3. ViewController의 역할 최대한 분리하는 방법 
1-1. MemoListViewController가 TableViewDataSource 역할을 하지않고 customDataSource를 따로 구현하였다.  
- 코드 
    ```swift
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
    ```

- `결론` : **모든 상황에 항상 적용되는 패턴, 코드라는 것은 없다.** 

- `생각의 흐름`
    - 'MVC 패턴에서 ViewController의 역할이 무엇인가'
    - Controller의 역할은 뷰에 내용을 주는 `presenter`의 역할을 하면서도 비지니스 로직이(`Model`) 앱의 필요 기능을 위해 배치되는 곳이라고 생각했다. 
        - 마치 레고(Model)를 가지고 사람, 성, 마을, 나라 등(Application) 을 만들 수 있는 것 처럼 
    - 이와 같은 이유로 ViewController가 TableView의 DataSource의 역할을 하는 것은 맞지 않다고 생각했다. 
    - 하지만  `UIKit에서 제공해주는 delegate에 더 필요한 부분이 있거나 override해야하거나 한다면 이점` 이 있는게 아니라면 굳이 두 번 거칠 필요없이 해당 컨트롤러에 delegate역할을 부여하는 것이 오히려 더 생산적인 방향일 수 있다. 
-  delegate, datasource등을 분리하는것을 모든 상황에 적용해야하는 법칙이 아니다. 
<br>

#### 4. 코어데이터 저장소는 어떤 객체가 가지고 있어야 할까
- `후보`
    - 지금은 기능 구현에 초점을 맞추고  Primary VC에 두었는데 추후 타입을 하나 만들어 들고있게 하거나 프로토콜로 만들 수 있지 않을까?
    - 코어 데이터가지는 프로토콜 하나 만들면  container도 extension으로 구현해 두고 fetch 하는 메소드도 가직 있도록 할 수 있을 것 같다. 

- `선택한 방향` : SplitVC가 MemoListVC, MemoDetailVC를 알고있기 때문에 CoreDataManager 객체를 만들어 이 객체가 데이터를 가지고 있으면서 SplitVC가 이 객체 접근하는 방식으로 최종 구현
 <br>
 
#### 5. TextView에서 제목과 본문을 나눠야 하는데 어떻게 나눌 수 있을까
- 아래와 같이 TextView의 text 속성을 분리하여 튜플로 반환하는 extension메소드를 사용해 보았다. 
```swift
extension String {
    func seperateTitleAndBody() -> (title: String, body: String) {
        let lineBreaker = "\n"
        let emptyTtitle = ""
        let bodyStartIndex = 1
        
        let seperateArrray = self.components(separatedBy: lineBreaker)
        let title = seperateArrray.first ?? emptyTtitle
        let body = seperateArrray[bodyStartIndex...].reduce("") { $0 + lineBreaker + $1 }
        
        return (title, body)
    }
}
```
<br>

#### 6. 코어데이터의 entity, attribute의 구성
- 메모의 title, body, date를 따로 나눠서 저장하는 방법과 통째로 저장하고 추후 필요할 때 가공해서 보여주는 방법 중 어떤것을 선택해야할까?
- `결론`
    - 현재는 두 방법의 차이가 크게 없을 것 같아서 구분하여 넣어주는 방법을 선택했다. 추후 프로젝트가 커지거나 프로젝트의 흐름이 바뀐다면 다시 한 번 고민해보면 좋을 것 같다.
 
<br> 
 
#### 7. MVC모델에 기반한 grouping
- `Model`의 기준 : `ViewController`에서 인스턴스로 만들어지거나 메소드의 매게변수, 내부 지역변수 등으로 사용되는가
- `View`의 기준 : 사용자에게 보여지는 UI요소와 관련되어 있는가
- `Controller`의 기준 : `View`와 `Model`의 상호작용이 구현되어있는가

    | | 
    | -------- | 
    | <img src = "https://i.imgur.com/RoqDKvm.png" width = 200, height = 500>|

<br>

#### 8. lazy키워드, closure를 이용해 UI요소를 초기화 하면 좋은 부분은 어디일까
- Closure
    - 해당 UI요소 자체의 속성을 다양하게 정해주어야 하는 경우
    - 구체적인 속성을 초기화 할 때 정할 수 있다는 장점이 있다. 
- lazy 키워드
    - 해당 키워드를 붙이는 상황
        - 사용자 interaction에 따라 생성 여부가 결정될 때
        - 화면에 로드를 빠르게 해주고 싶을 때 
- 프로젝트에서 사용한 부분
```=swift
//MemoDetailViewController
private lazy var textView = UITextView()
                
//MemoListViewController
private lazy var tableView = UITableView()
```

<br>

#### 9. `CellId`열거형
- cell identifier를 cell 타입 내부에서 private 속성으로 가지는 방법과 CellID라는 enum을 구현하는 방법 중 어떤방법이 더 코드의 가독성, SOLID 측면에서 좋을까
- `결론` : cell identifier라는 건 결국 cell의 이름이기 때문에 cell 내부에 property로가지고 있는것이 좋을 것 같다고 생각하였다. 


</div>
</details>


<br>

# 학습내용
- 3주간 배운 내용을 정리해 보았다. [노션 링크](https://www.notion.so/_-f68835bfaf6d4277971d01ceb2142166)

<br><br>

# 아쉬운 부분 
1. 코어데이터의 에러처리 
2. `Nested Stack View` 구현하지 못했던 부분 
3. `MemoDetailViewController`의 `textViewDidChange` 메소드에서 텍스트뷰의 `text`속성 값이 변경 될 때마다 메모를 저장하고 있는 것
4. 메모를 저장할 때 user default 가 아닌 keychain에 저장하도록 구현하면 더 안전한 저장 방식이 될 수 있었던 점  

1. 더보기 버튼 눌렀을 때 메모 삭제 후 커서가 남아있는 현상 
2. 테이블뷰에 제목, 날짜, 본문이 잘 반영되고 있었는데 어느순간 body가 반영이 되지가 않음

4. `textViewDidChange` 메소드 내부에서 메모의 생성날짜 업데이트가 항상 진행되는 부분

6. 나의 태도
- 처음 오토레이아웃 경고창이 나왔을 때 우선 화면에 잘 보이니 나중에 고쳐보자는 마음으로 넘어갔다. 하지만 아래와 같은 문제가 나중에 발생하였다. 버그엔 사소한게 없다. 해결하고 넘어가자 
- 커밋할 때 빌드되는지 확인안하고 간것. 어느순간 커밋에만 집중했던 것 같다(그 내용이 아니라). 근데 이게 쉽게고쳐지지가 않을 것 같다. 기본적인 것이 가장 중요하니 항상 유의하도록 하자 
- 옵셔널을 많이 쓰는 것같다... 옵셔널을 과하게 사용하면 어디서 nil인지 알수가 없다는 단점이 있다!!
    <br><br>

---
##### 이번 프로젝트를 진행하면서 경험했던 리팩토링에 관하여 
- 속이시원하다 


| <리팩토링 전> |<리팩토링 후> |
| -------- | -------- |
| <img src = "https://i.imgur.com/k3T1rWC.png" width = 200, height = 200>     | <img src = "https://i.imgur.com/tHDy1v7.png" width = 200, height = 200>     |

---

---

# 추가하지 않은 부분


아래의 코드를 구현하면 정상적으로 dateLable, bodyLabel의 컨텐츠가 출력된다. 
        ```swift
        bodyLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) 
        ```
    2. safeAreaLayout으로 leading anchor를 설정하면 stack뷰가 잘 나왔던 이유


# 구현 기능

### Self sizing cell (Dynamic type surpport)
### 6. Update Date 
- 구현 기능 : 텍스트뷰의 내용이 변경된 날짜를 업데이트 해주기  
        <details>
        <summary>기존코드</summary>
        - 기존 코드 
        ```swift
        extension DateFormatter {
            func updateLastModifiedDate( lastModifiedDateInt: Int?) -> String {
                let customDateFormatter = customDateFormatter()
                let date = Date(timeIntervalSince1970: Double(lastModifiedDateInt ?? .zero))
                let dateString = customDateFormatter.string(from: date)

                return dateString
            }

            private func customDateFormatter() -> DateFormatter {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                formatter.locale = Locale(identifier: "koKR")
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
        </div>
        </details>
    
- 리팩토링 코드 
    - 코어데이터 attribute의 타입을 Date로 변경하여 `Int64`타입으로 바꾸는 단계를 제거하였다. (CoreDataMigration 진행)
    - cell에서 content를 표시하는 부분에서 아래 `updateLastModifiedDate` 메소드를 이용해 String으로 변경하였다. 
        ```swift
        extension DateFormatter {
            func updateLastModifiedDate( lastModifiedDate: Date) -> String {
            let customDateFormatter = customDateFormatter()
            let dateString = customDateFormatter.string(from: lastModifiedDate)
        
            return dateString
            }
    
            private func customDateFormatter() -> DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "koKR")
            formatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")

            return formatter
            }
        }

        ```










# 트러블슈팅




#### 텍스트뷰의 바디에 해당하는 부분을 입력하려고 할 때 테이블뷰의 레이아웃이 바뀌는 현상 



수정코드 

### SplitView




#### 컴팩트 였다가 레귤러로 바뀌면 두개의 뷰 모두 글자뜨는 현상


|![](https://i.imgur.com/UmR2lko.gif) | 
| -------- | 



```swift=
if splitViewController?.isCollapsed == true {
    let secondVC = splitViewController?.viewController(for: .secondary) as? SecondaryViewController
    secondVC?.text = "\(MemoDataHolder.list?[indexPath.row].title)" + "\(MemoDataHolder.list?[indexPath.row].body)" splitViewController?.showDetailViewController(secondVC ?? SecondaryViewController(), sender: nil)
 } else { 
    let naviVC = splitViewController?.viewControllers.last as? UINavigationController
    let secondVC = naviVC?.viewControllers.last as? SecondaryViewController
    splitViewController?.preferredSplitBehavior = .tile
    secondVC?.textView.text = "\(MemoDataHolder.list?[indexPath.row].title)" + "\(MemoDataHolder.list?[indexPath.row].body)"
    splitViewController?.show(.primary)
 }
```


- 이유 : 레귤러 사이즈 일 때 스플릿 뷰는 하나의 네비게이션 컨트롤러에서 뷰의 계층을 관리하기 때문에 첫 번째 뷰에서도 두번째 뷰와 같은 내용이 나오게 된다.

// splitview정리해서 추가하기 





#### 추가해야하나 Cell에 UIButton추가하기  accessoryView에 관하여
- `상황` : cell의 accessoryView타입이 아닌 UIButton을 직접 추가해서 구현시도

    | 디버깅콘솔 | 에러 로그 |
    | -------- | -------- |
    | ![](https://i.imgur.com/P4KghOi.png) |   ![](https://i.imgur.com/0uHGpwR.png)|

    ```swift=
    private func makeButtonLayout() {
        self.detailButton = UIButton()
        contentView.addSubview(detailButton)
        detailButton.setAnchor(top: contentView.topAnchor,
                               bottom: contentView.bottomAnchor,********
                               leading: nil,
                               trailing: contentView.trailingAnchor)
    }
    ```
- `시도1` : hugging, compression 값 설정 → 실패
- `시도2` : width 값 직접 설정 ,  실패
- `시도3` : 시도1,2 동시 - > 실패
- `시도4` : tableviewdelegate 메소드로 row의 높이 지정  → 하지만 오토레이아웃 경고는 사라지지 않음 
- `해결` : cell의 accessaryView 타입을 지정해 주었다. 

- `결론` : 기존 titleLabel, stackView의 vertical position즉 각 label의 수직상의 위치가 제대로 결정되지 않아 하나로 겹쳐진 것 




