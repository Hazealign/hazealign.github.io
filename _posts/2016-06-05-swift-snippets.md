---
layout: post
title: "[번역] 쓰기 시작하면 멈출 수 없어지는 Swift Extension 모음"
date: 2016-06-05 12:00:00 +0900
categories: Code
tags: ios swift development async color string featured
---

이 글은 tattn님이 Qiita에 올린 [글](http://qiita.com/tattn/items/647e094936287a6bd2d3)을 한국어로 번역한 글입니다. 번역을 허락해주신 tattn님께 감사합니다. Swift를 쓰면서 생산성을 높여주는 짤막한 코드들이 인상적입니다. 혹시 어떤 부분이 제일 인상적이었는지 댓글로 남겨주셔도 좋을 것 같습니다.

범용성 높은 Extension 집입니다. 후반에 있는 라이브러리도 정리했습니다. Swift 2.2 기준으로 확인되었습니다.

## 클래스 이름의 표시

```swift
extension NSObject {
    class var className: String {
        return String(self)
    }

    var className: String {
        return self.dynamicType.className
    }
}

MyClass.className   //=> "MyClass"
MyClass().className //=> "MyClass"
```

## XIB를 등록하고 호출하기

XIB 파일과 클래스 이름을 똑같이 설정한 뒤 이용해주세요. 위에서 이야기한 "클래스 이름의 표시"를 활용하고 있습니다.

### UITableView

```swift
extension UITableView {
    func registerCell<T: UITableViewCell>(type: T.Type) {
        let className = type.className
        let nib = UINib(nibName: className, bundle: nil)
        registerNib(nib, forCellReuseIdentifier: className)
    }

    func registerCells<T: UITableViewCell>(types: [T.Type]) {
        types.forEach { registerCell($0) }
    }

    func dequeueCell<T: UITableViewCell>(type: T.Type, indexPath: NSIndexPath) -> T {
        return self.dequeueReusableCellWithIdentifier(type.className, forIndexPath: indexPath) as! T
    }
}
```

```swift
tableView.registerCell(MyCell.self)
tableView.registerCells([MyCell1.self, MyCell2.self])

let cell = tableView.dequeueCell(MyCell.self)
```

## UICollectionView

```swift
extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(type: T.Type) {
        let className = type.className
        let nib = UINib(nibName: className, bundle: nil)
        registerNib(nib, forCellWithReuseIdentifier: className)
    }

    func registerCells<T: UICollectionViewCell>(types: [T.Type]) {
        types.forEach { registerCell($0) }
    }

    func registerReusableView<T: UICollectionReusableView>(type: T.Type, kind: String = UICollectionElementKindSectionHeader) {
        let className = type.className
        let nib = UINib(nibName: className, bundle: nil)
        registerNib(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }

    func registerReusableViews<T: UICollectionReusableView>(types: [T.Type], kind: String = UICollectionElementKindSectionHeader) {
        types.forEach { registerReusableView($0, kind: kind) }
    }

    func dequeueCell<T: UICollectionViewCell>(type: T.Type, forIndexPath indexPath: NSIndexPath) -> T {
        return dequeueReusableCellWithReuseIdentifier(type.className, forIndexPath: indexPath) as! T
    }

    func dequeueReusableView<T: UICollectionReusableView>(type: T.Type, indexPath: NSIndexPath, kind: String = UICollectionElementKindSectionHeader) -> T {
        return dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: type.className, forIndexPath: indexPath) as! T
    }
}
```

```
collectionView.registerCell(MyCell.self)
collectionView.registerCells([MyCell1.self, MyCell2.self])
let cell = collectionView.dequeueCell(MyCell.self)

collectionView.registerReusableView(MyReusableView.self)
collectionView.registerReusableViews([MyReusableView1.self, MyReusableView2.self])
let view = collectionView.dequeueReusableView(type: MyReusableView.self, indexPath: indexPath)
```

## 16진수를 이용해서 NSColor 만들기

```swift
extension UIColor {
    convenience init(hex: Int, alpha: Double = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
}
```

```swift
let color = UIColor.color(0xAABBCC)
```

## 제일 최상위 UIViewController 객체를 가져오기

```swift
extension UIApplication {
    func topViewController() -> UIViewController? {
        guard var topViewController = UIApplication.sharedApplication().keyWindow?.rootViewController else { return nil }

        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}
```

```swift
UIApplication.sharedApplication().topViewController()?
```

## Storyboard의 ViewController 생성하기

```swift
protocol StoryBoardHelper {}

extension StoryBoardHelper where Self: UIViewController {
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: self.className, bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(self.className) as! Self
    }

    static func instantiate(storyboard: String) -> Self {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(self.className) as! Self
    }
}

extension UIViewController: StoryBoardHelper {}
```

```
// Storyboard 파일과 클래스 이름이 같을 때
MyViewController.instantiate()
// Storyboard 파일과 클래스 이름이 다를 때
MyViewController.instantiate("MyStoryboard")
```

 위에서 이야기한 "클래스 이름의 표시"를 활용하고 있습니다.
 
## XIB의 View를 생성

```
protocol NibHelper {}

extension NibHelper where Self: UIView {
    static func instantiate() -> Self {
        let nib = UINib(nibName: self.className, bundle: nil)
        return nib.instantiateWithOwner(nil, options: nil)[0] as! Self
    }
}

extension UIView: NibHelper {}
```

```
MyView.instantiate(owner: self)
```

XIB 파일과 클래스 이름을 똑같이 설정한 뒤 이용해주세요. 위에서 이야기한 "클래스 이름의 표시"를 활용하고 있습니다.

## 모든 자식 View를 죽이기

```swift
extension UIView {
    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}
```

```swift
view.removeAllSubViews()
```

## Selector를 모으기

```swift
private extension Selector {
    static let buttonTapped = #selector(MyViewController.buttonTapped(_:))
}
```

```swift
let button = UIButton()
button.addTarget(self, action: .buttonTapped, forControlEvents: .TouchUpInside)
```

## 라이브러리
개발을 쉽게 해주는 다용도 extension 계의 라이브러리를 정리했습니다.

### [SwiftDate](https://github.com/malcommac/SwiftDate)

NSDate를 쉽게 쓸 수  있게 만들어주는 라이브러리

```swift
let date1 = NSDate(year: 2016, month: 12, day: 25, hour: 14)
let date2 = "2016-01-05T22:10:55.200Z".toDate(DateFormat.ISO8601)
let date3 = "22/01/2016".toDate(DateFormat.Custom("dd/MM/yyyy"))
let date4 = (5.days + 2.hours - 15.minutes).fromNow
let date5 = date4 + 1.years + 2.months + 1.days + 2.hours
```

더 자세히 알고 싶으신 분들은 [여기](https://github.com/malcommac/SwiftDate/blob/master/Documentation/UserGuide.md)에서.

### [Chameleon](https://github.com/ViccAlexander/Chameleon)

![]({{ site.url }}/assets/images/20160605/1.png)

좋은 느낌의 플랫 컬러를 제공해주는 라이브러리

```swift
let color1 = UIColor.flatGreenColorDark()
let color2 = FlatGreenDark() // 위의 축약형
let color3 = RandomFlatColor()
let color4 = ComplementaryFlatColorOf(color1) // 보색

UIColor.pinkColor().flatten()
FlatGreen.hexValue //=> "2ecc71"
UIColor(averageColorFromImage: image)
```

컨트롤의 색을 일괄적으로 변경하는 것도 가능합니다.

```swift
Chameleon.setGlobalThemeUsingPrimaryColor(FlatBlue(), withSecondaryColor: FlatMagenta(), andContentStyle: UIContentStyle.Contrast)
```

### [R.swift](https://github.com/mac-cain13/R.swift)

안드로이드의 R.java와 같이 파일 이름 등을 프로퍼티화해주는 라이브러리입니다. Typo가 컴파일 시점에 알 수 있으니 행복해집니다.

Before
```swift
let icon = UIImage(named: "settings-icon")
let font = UIFont(name: "San Francisco", size: 42)
let viewController = CustomViewController(nibName: "CustomView", bundle: nil)
let string = String(format: NSLocalizedString("welcome.withName", comment: ""), locale: NSLocale.currentLocale(), "Arthur Dent")
```

After
```swift
let icon = R.image.settingsIcon()
let font = R.font.sanFrancisco(size: 42)
let viewController = CustomViewController(nib: R.nib.customView)
let string = R.string.localizable.welcomeWithName("Arthur Dent")
```

### [SwiftString](https://github.com/amayne/SwiftString)

String에 편리한 메소드를 추가해주는 라이브러리입니다.

```swift
"foobar".contains("foo")         //=> true
",".join([1,2,3])                //=> "1,2,3"
"hello world".split(" ")[1]      //=> "world"
"hello world"[0...1]             //=> "he"
"hi hi ho hey hihey".count("hi") //=> 3
```

### [SwiftyUserDefaults](https://github.com/radex/SwiftyUserDefaults)

NSUserDefaults를 Swift스럽게 쓰게 해주는 라이브러리입니다.

```swift
extension DefaultsKeys {
    static let username = DefaultsKey<String?>("username")
    static let launchCount = DefaultsKey<Int>("launchCount")
}

// 값을 가져오거나 설정하기
let username = Defaults[.username]
Defaults[.hotkeyEnabled] = true

// 값의 변경
Defaults[.launchCount]++
Defaults[.volume] += 0.1
Defaults[.strings] += "… can easily be extended!"

// 배열의 작업
Defaults[.libraries].append("SwiftyUserDefaults")
Defaults[.libraries][0] += " 2.0"

// 커스텀 타입도 OK
Defaults[.color] = NSColor.whiteColor()
Defaults[.color]?.whiteComponent // => 1.0
```

### [TextAttributes](https://github.com/delba/TextAttributes)

![]({{ site.url }}/assets/images/20160605/2.gif)

NSAttributedString를 쉽게 설정할 수 있는 라이브러리입니다.

```swift
let attrs = TextAttributes()
    .font(name: "HelveticaNeue", size: 16)
    .foregroundColor(white: 0.2, alpha: 1)
    .lineHeightMultiple(1.5)

NSAttributedString("ほげ", attributes: attrs)
```

### [Async](https://github.com/duemunk/Async)

Grand Central Dispatch (GCD)를 쉽게 쓰게 해주는 라이브러리입니다.

Before
```swift
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
    print("This is run on the background queue")

    dispatch_async(dispatch_get_main_queue(), {
        print("This is run on the main queue, after the previous block")
    })
})
```

After
```swift
Async.background {
    print("This is run on the background queue")
}.main {
    print("This is run on the main queue, after the previous block")
}
```

### [AsyncKit](https://github.com/mishimay/AsyncKit)

[http://qiita.com/mishimay/items/7df447969a1c38d856d8](http://qiita.com/mishimay/items/7df447969a1c38d856d8)

여러 비동기 처리를 끝낸 뒤 다음 작업을 할 수 있게 도와주는 라이브러리입니다.

```swift
let async = AsyncKit<String, NSError>()

async.parallel([
    { done in done(.Success("one")) },
    { done in done(.Success("two")) }
]) { result in
    print(result) //=> Success(["one", "two"])
}
```