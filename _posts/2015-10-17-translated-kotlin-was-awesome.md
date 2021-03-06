---
layout: post
title: "[번역] Android 개발을 수주해서 Kotlin을 제대로 써봤더니 최고였다."
date: 2015-10-17 00:00:00
categories: Code
tags: translate android kotlin swift
---

## 글에 앞서

이 글은 일본의 omochimetaru님이 Qiita에 올린 [Android 개발을 수주해서 Kotlin을 제대로 써봤더니 최고였다.](http://qiita.com/omochimetaru/items/98e015b0b694dd97f323)라는 글을 번역해서 만들었습니다. 번역을 흔쾌히 허락해주신 omochimetaru님께 감사하다는 말씀 드립니다. 또한 글에서 한국에서는 쓰이지 않는 표현들 등에 대해서는 의역이 섞여있습니다. 이 점 양해 부탁드립니다. 늦은 시간까지 오역을 찾고 번역의 질을 높이는데 많은 도움을 주시고 오히려 저보다 많이 고생해주신 이상한모임의 pluulove님, chiyodad님, lemonade님께도 감사하다는 말씀 드립니다. 읽어주셔서 감사합니다.

## Kotlin을 실무 프로젝트에서 사용했습니다.

며칠 전, 제가 소속된 [Qoncept](http://qoncept.co.jp/)에서 ["리얼 술래잡기"x후지큐 하이랜드 거대 유원지에서부터의 도주](http://www.real-toso.jp/)를 개발했고 출시했습니다.

후지큐 하이랜드에서 실제 술래잡기를 하는데, 일반 손님들이 스마트폰으로 전용 애플리케이션을 사용하며 클리어하는 것을 목표로 하는 기획이었습니다. 유원지에는 도깨비 역할의 스태프와 게임 진행에 관련된 시설이 있습니다. 그것들과 스마트폰이 iBeacon(Bluetooth LE)을 사용하여 연동하며 데미지를 입는거나, 아이템을 쓰거나, 퀴즈를 푸는 것 등을 할 수 있습니다.

Qoncept의 개발 범위는 iOS 앱(과 애플워치용 앱), 안드로이드 앱, 서버사이드였습니다.

수주가 확정된 시점에서 남은 개발 기간과 개발자 인원에 비해 전체 개발 범위가 꽤 컸기 때문에 어떻게하면 기간 내에 맞출 수 있을까 검토하였습니다. 그 당시에는 iOS는 Swift를 이용해서 Objective-C보다 쾌적한 개발이 가능해졌었지만 Android에서의 Java를 이용한 개발에는 부담감을 가지고 있었습니다. 그래서 생각해낸 것이 Kotlin이었습니다. 이전부터 이따금씩 들었던지라 어쩐지 좋은 언어 같다는 인식이 있었습니다. Kotlin을 쓰려면 지금이 적기라고 생각하며 공식 사이트의 문서를 단숨에 읽어보았습니다. 이거라면 할 수 있겠다고 판단해서, **iOS 앱은 Swift로 개발하고 동시에 Android에는 Kotlin으로 이식하여 구현하는 것**을 방침으로 삼았습니다.

최종적으로는 스케쥴에도 정확히 맞출 수 있었고, 앱도 안정적이었습니다. 게다가 [손님들로부터의 평가](https://twitter.com/real_toso)도 좋았기 때문에 행복하게 마무리 되었다 생각합니다.

### Kotlin 진짜 최고

서문이 길어졌지만, 앞서 이야기했던 것과 같이 Kotlin으로 제대로 개발해봤더니 Kotlin이 최고라는 것을 만끽할 수 있었습니다. (iOS 앱은 다른 분이 개발하셨고, Android 앱으로의 이식은 제가 담당했습니다.)
이런 마음이 더욱 부풀어 올라서, Kotlin 개발자가 늘어나 널리 보급되어 앞으로도 Kotlin이 진화하고 보완될 수 있으면 좋겠다는 생각으로 Kotlin을 전파하기 위해 이번 글을 쓰게 되었습니다.

아래에서는 Kotlin을 주로 Android 개발에, Swift로부터의 이식, 실무에서의 사용을 중점적으로 해서 소개하고자 합니다.

#### 버전

실제 프로젝트 당시에는 M11 버전으로 구현했습니다.
글을 쓴 시점에서 M14 버전이 나왔으며, 알아차린 범위 내에서 M14 버전에 맞는 내용으로 글을 쓰고 있습니다.

## 언어 주변 환경

언어의 사양을 보기 전에 우선, Kotlin이라는 언어의 주변 환경에 대해 먼저 써보겠습니다.

### 후원하는 기업은 어떤 기업인가?

취미로 개발하는 것과는 달리 실무 개발의 경우 유명하지 않은 언어는 개발이 중단되거나 나중에 언어가 없어지는 위험 부담이 있습니다. 이 점에서 Kotlin은 대중적으로 인지도는 떨어지지만 오픈 소스로 만들어지고 있기 때문에, 갑자기 컴파일러 같은 것들을 받을 수 없게 되는 일은 없을 것으로 여겨집니다.

또한, 개발을 주도하고 있는 업체는 Jetbrains입니다. Jetbrains는 IntelliJ IDEA라고 하는 IDE를 개발하고 판매하는 회사로 유명합니다. Java IDE를 개발하고 있는 수준이기 때문에, 컴파일러와 관련된 기술력이나 프로그래밍 언어에 대한 이해는 상당할 것이라고 생각합니다. Android의 개발 환경이 Eclipse + ADT에서 Android Studio로 전환된지 오래지만, 이 Android Studio는 IntelliJ를 Android 개발을 위하여 고친 버전입니다. 구글이 이렇게 개발 환경을 변경한 것도, Jetbrains에 대한 신뢰를 높이는데 일조하고 있습니다.

### 도입이 간단하다.

새로운 언어를 도입하고자 할 때는 개발 환경 구축에 문제가 생겨 시간이 오래 걸리고, 제대로 된 개발 환경이 갖춰져 있지 않을 때 오히려 언어 자체의 개발 생산성을 개발 환경이 상쇄할 수 있는 우려가 있습니다.

Kotlin은 이 부분이 재미있습니다. 우선 IDE에 연동하기 위한 IntelliJ(Android Studio)용 플러그인을 Jetbrains에서 제공하고 있습니다. 같은 회사에서 IDE와 언어를 만들기 떄문에 각종 지원이 확실합니다. Swift + XCode에서는 할 수 없는 Refactor rename 등의 기능도 기본적으로 제공하고 있습니다.

플러그인은 `Android Studio > Preferences > Plugins > Install Jetbrains Plugin > Kotlin`에서 설치할 수 있습니다. 새로운 버전의 플러그인이 나왔을 때는 Android Studio가 알려주기 때문에 간단하게 업데이트할 수 있습니다.

프로젝트 빌드에 도입하는 것 또한 간단합니다.

`Android Studio > Tools > Kotlin > Configure Kotlin in Project`를 클릭하면 다이얼로그가 나와서, OK 버튼을 누르면 자동으로 설치합니다. 그러면 애플리케이션 모듈의 gradle 파일이 아래처럼 바뀝니다.

##### Kotlin 도입 전

{% highlight groovy %}
apply plugin: 'com.android.application'

android {
    compileSdkVersion 22
    buildToolsVersion "22.0.1"

    defaultConfig {
        applicationId "jp.co.qoncept.apptest"
        minSdkVersion 18
        targetSdkVersion 22
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    compile 'com.android.support:appcompat-v7:22.2.0'
}
{% endhighlight %}

##### Kotlin 도입 후

{% highlight groovy %}
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'

android {
    compileSdkVersion 22
    buildToolsVersion "22.0.1"

    defaultConfig {
        applicationId "jp.co.qoncept.apptest"
        minSdkVersion 18
        targetSdkVersion 22
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    compile 'com.android.support:appcompat-v7:22.2.0'
    compile "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
}

buildscript {
    ext.kotlin_version = '0.13.1514'
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
repositories {
    mavenCentral()
}
{% endhighlight %}

나머지는 빌드해주면, Gradle 스크립트가 Kotlin 컴파일러의 다운로드부터 환경 설정까지 자동으로 전부 알아서 해줍니다. 새로운 버전의 Kotlin이 나왔다면 `ext.kotlin_version` 부분을 고쳐주면 됩니다.

### Java와의 연계 기능이 강력하다.

개발 언어를 변경하는 경우 지금까지 써오던 언어와의 동시 사용이 어렵거나, 원활하지 않을 경우 기존 프로젝트에 추가로 도입할 수도 없으며 과거의 코드 리소스가 낭비되고, 만에 하나 문제가 발생하는 경우를 피할 수가 없습니다.

그 점에서 볼 때 Kotlin은 Java와의 연계 능력이 정말로 강력합니다. Scala나 Groovy와 마찬가지로 Java 바이트코드로 컴파일되어서, JVM 위에서 구동될 수 있습니다.

언어 사양에서 우선 Java와의 연계가 중요시되고 있으며, 기존 Java 기반 프로젝트에 Kotlin 소스를 섞어서 사용할 수 있도록 되어있습니다. 또, Kotlin에서 자연스럽게 Java의 클래스나 메소드를 호출할 수 있습니다. 공식 사이트에서도 [100% interoperable with Java](http://kotlinlang.org/)라고 나와있습니다. Kotlin을 잘 쓰지 못하더라도, 그 부분만 기존 Java 소스 코드로 쓰는 것 또한 가능합니다.

## 언어 소개

### 타입 추론을 지원하는 정적 타이핑

Kotlin은 타입 추론을 지원하는 정적 타이핑 언어입니다. Swift도 그렇지만, Java하고는 다릅니다. 타입 추론은 기본이죠.

### 외형

{% highlight kotlin %}
fun main(args: Array<String>) {
    println("Hello, world!")
}
{% endhighlight %}

세미콜론 없는 스타일, 코드 블록은 중괄호로 여닫는 스타일, 형태 표기는 Pascal 스타일(변수, 콜론, 자료형의 순서)을 볼 수 있습니다.

{% highlight kotlin %}
var sum = 0

listOf(1,2,3).filter { it > 0 }.forEach {
  sum += it
}

print(sum)
{% endhighlight %}

클로져의 경우 중괄호`{}`만 쓰기 때문에 마지막 인자의 클로져를 함수 호출 뒤에 쓰고, 그 때 인자가 없으면 소괄호`()`를 생략할 수 있습니다.

이쪽의 구문 사양이 Swift와 동일하기 때문에, 이식 작업이 편해집니다.

### Optional (Nullable)

자료형으로 null을 참조할 수 있는 자료형과 없는 자료형이 구분됩니다. 타입을 검사하고 내용이 null인지 아닌지를 확인하면 그 시점에서 내용의 자료형으로 형변환됩니다. 일반적으로 이런 기능들을 제공할 떄 Optional이라고 하는데 Kotlin에서는 이 기능을 Nullable이라고 합니다.

{% highlight kotlin %}
fun getLengthOfString(str: String): Int {
    return str.length()
}

fun getLengthOfStringOpt(str: String?): Int {
    if (str != null) {
        return getLengthOfString(str)
    } else {
        return 0
    }
}

fun main(args: Array<String>) {
    val a = getLengthOfString("hello")
    val b = getLengthOfStringOpt("world")
    val c = getLengthOfStringOpt(null)
    println("$a, $b, $c")
}
{% endhighlight %}

Nullable 자료형은 자료형의 오른쪽에 물음표`?`를 붙여 표기합니다. Swift의 Optional과 같아서 기쁩니다. Java의 언어 기능에 Optional은 존재하지 않습니다. 아마 NullPointerException으로 죽겠죠.

#### 약간 특이한 부분

Nullable의 Nullable을 만들 수가 없습니다. 그냥 Nullable이 되어버립니다.
Swift에서 Optional의 Optional이 나올 때 어떻게 이식할지 고민하게 됩니다.

{% highlight kotlin %}
fun wrap(a: Int?): Int?? {
    return a
}

fun desc(a: Int??) {
    if (a == null) {
        println("None")
    } else {
        if (a == null) {
            println("Some(None)")
        } else {
            println("Some(Some($a))")
        }
    }
}

fun main(args: Array<String>) {
    val a: Int?? = wrap(null)
    desc(a) // Some(None)이 나와야하지만, None이 되어버린다.
}
{% endhighlight %}

### 플로우 기반 형변환 (Smart Casts)

if 문에서 null인지를 체크하거나, is 연산자를 통해 타입을 검사하면 Kotlin에서는 그것을 고려해서 자동으로 형변환됩니다.

{% highlight swift %}
open class Animal {}
class Cat: Animal() {
    fun nyaa() { println("nyaa") }
}
class Dog: Animal() {
    fun wan() { println("wan") }
}

fun speak(animal: Animal) {
    if (animal is Cat) { animal.nyaa() }
    if (animal is Dog) { animal.wan() }
}
fun speak2(animal: Animal?) {
    if (animal == null) {
        println("null")
        return
    }
    speak(animal)
}

fun main(args: Array<String>) {
    speak2(Cat()) // nyaa라고 나옴
    speak2(Dog()) // wan이라고 나옴
    speak2(null) // null이라고 나옴
}
{% endhighlight %}

speak2의 앞 부분에서 null 인지를 체크하고 return 하고 있으므로 if 이후 `Animal?`이 아니라 `Animal` 자료형으로 변했으며, speak가 호출될 수 있습니다. speak의 if문의 분기에서 is를 이용한 체크를 통해 서브클래스인 `Cat`이나 `Dog`로 변해있으며 전용 메소드를 호출할 수 있습니다.

동일한 코드에 대한 Swift 버전은 아래와 같습니다.

{% highlight swift %}
class Animal {}
class Cat: Animal {
    func nyaa() { print("nyaa") }
}
class Dog: Animal {
    func wan() { print("wan") }
}

func speak(animal: Animal) {
    if let animal = animal as? Cat { animal.nyaa() }
    if let animal = animal as? Dog { animal.wan() }
}
func speak2(animal: Animal?) {
    guard let animal = animal else {
        print("null")
        return
    }
    speak(animal)
}

func main() {
    speak2(Cat())
    speak2(Dog())
    speak2(nil)
}

main()
{% endhighlight %}

speak2에서는 이를 위해 일부러 guard 문이라는 것을 사용하지 않으면 안됩니다. speak, speak2 둘 다 `let animal = `을 쓰는 것이 중복됩니다. if 괄호를 생략할 수 있는 것은 좋네요.

Java에서는 아마 아래와 같이 되겠죠.

{% highlight java %}
import java.util.*;
import java.lang.*;
import java.io.*;

class Animal {}
class Cat extends Animal {
    void nyaa() { Ideone.print("nyaa"); }
}
class Dog extends Animal {
    void wan() { Ideone.print("wan"); }
}

class Ideone {
    public static void print(String str) { System.out.println(str); }

    static void speak(Animal animal) {
        if (animal instanceof Cat){
            Cat cat = (Cat)animal;
            cat.nyaa();
        }
        if (animal instanceof Dog) {
            Dog dog = (Dog)animal;
            dog.wan();
        }
    }
    static void speak2(Animal animal) {
        if (animal == null) {
            print("null");
            return;
        }
        speak(animal);
    }

    public static void main (String[] args) throws java.lang.Exception {
        speak2(new Cat());
        speak2(new Dog());
        speak2(null);
    }
}
{% endhighlight %}

null 체크에 관련해서는 그저 코드가 올바르길 기도하고 실행하는 수밖에 없습니다. 그리고 speak의 내용은 `Cat`과 `Dog`가 각각 세 번씩 나옵니다. (형변환용 메소드를 만든다면 2번 + null 체크로 줄일 수는 있겠지만요.)

### Unsafe cast

Nullable이 null일 땐 충돌이 나는 내용의 추출과 타입이 다를 경우에는 충돌하는 형변환이 있습니다.

{% highlight kotlin %}
fun hoge(a: Int?, b: Animal?) {
    val c: Int = a!! // null이라면 Exception
    val d: Cat? = b as? Cat // Cat이 아니라면 null
    val e: Cat = b as Cat // Cat이 아니라면 Exception
}
{% endhighlight %}

Swift에서는 아래와 같이 작성할 수 있겠죠.

{% highlight swift %}
func hoge(a: Int?, b: Animal?) {
    let c: Int = a! // nil이라면 Exception
    let d: Cat? = b as? Cat // Cat이 아니라면 nil
    let e: Cat = b as! Cat // Cat이 아니라면 Exception
}
{% endhighlight %}

Kotlin에서는 두개의 느낌표`!`로 처리합니다. Swift에서는 한개죠.
위험한 as에서는 Swift에서는 느낌표가 붙어있습니다.

### Optional의 메소드 호출

Kotlin에서는 Optional로 둘러쌓인 값의 메소드를 호출할 때, 값이 있다면 메소드를 호출할 수 있고 null일 경우에는 null값이 필요할 때, if문에서의 타입 체크를 하지 않고도 다음과 같이 작성할 수 있습니다.

{% highlight kotlin %}
fun hoge(user: User?) {
    val name: String? = user?.name
    println("name=$name")
}
{% endhighlight %}

Elvis 연산자를 사용하면 null인 경우 기본값을 지정할 수 있습니다.

{% highlight kotlin %}
fun hoge(user: User?) {
    val name: String = user?.name ?: "no name"
    println("name=$name")
}
{% endhighlight %}

Swift에서도 물음표 + 점`?.`으로 쓰이는 메소드 호출이 있습니다. 또한 elvis 연산자에 대해서는 Swift에서는 물음표 두개`??`입니다.
비슷해보이는 두 언어지만, 물음표 + 점`?.`을 연속해서 사용할 때에는 구문 트리가 달라집니다.
사용자 이름의 문자 수를 가져오는 경우를 생각해보세요.

{% highlight kotlin %}
class User {
    var name: String = "tanaka"
}

fun hoge(user: User?) {
    println(user?.name?.length())
}
{% endhighlight %}

Kotlin에서는 `?.`가 두번 나옵니다. 이것은 다음과 같이 해석할 수 있습니다.

{% highlight kotlin %}
( user?.name )?.length()
{% endhighlight %}

`?.`을 쓰지 않는 경우에는 아래와 같이 쓸 수 있겠습니다.

{% highlight kotlin %}
val name: String? = if (user != null) { user.name } else { null }
val length: Int? = if (name != null) { name.length } else { null }
{% endhighlight %}

마찬가지를 Swift에서는 아래와 같이 표현할 수 있습니다.

{% highlight swift %}
class User {
    var name: String = "tanaka"
}

func hoge(user: User?) {
    print(user?.name.characters.count)
}

main()
{% endhighlight %}

name 뒤에 `?.`가 Swift에서는 `.`로 나와있습니다. 이것은 아래와 같이 해석되기 때문입니다.

{% highlight swift %}
user?.( name.characters.count )
{% endhighlight %}

하지만, 이 괄호는 개념을 설명하기 위해서 임의로 만든 것이며 Swift로는 올바른 문법이 아닙니다. 고쳐서 쓴다면 아래와 같습니다.

{% highlight swift %}
if let user = user {
    return user.name.characters.count
} else {
    return nil
}
{% endhighlight %}

정리하면 다음과 같습니다. Kotlin의 경우 `?.`을 다음 번만의 키워드만 처리하고 그 결과를 다음에도 사용합니다. Swift의 경우에는 `?.`을 오른쪽 모두를 묶어버리며 None일 경우 오른쪽 모두를 스킵합니다. 이 차이는 똑같은 외형의 코드가 전혀 다른 의미를 가지게 된다는 뜻이므로 이식하는데는 주의할 필요가 있습니다.

개인적으로는 Kotlin의 사양이 더 직관적이고 좋았습니다. 처음 Swift로 개발했을 때 Kotlin의 사양을 상상하고 작업하다가 에러가 나서 당황했던 적이 있었습니다.

Java의 경우에는 첫 번째 인자로 리시버를 두 번째 인자로 오퍼레이터를 갖는 콜백 함수를 만들고 `?.` 동작을 에뮬레이트하는 것이 좋겠죠. if문을 쓰면 리시버의 식을 두 번 쓰지 않으면 안되기 때문입니다.

### 메소드 호출은 아니지만, Optional에 체인 가능한 것들

위에서 쓴 `?.`을 사용하면 Optional이어도 귀찮지 않게 코드를 짤 수 있습니다만 아래와 같이 `?.`로는 쓸 수 없지만 null이 아닌 경우 처리를 계속하고 싶은 케이스가 있습니다.

{% highlight kotlin %}
val result: Boolean

if (user != null) {
    result = write(user)
} else {
    result = false
}
{% endhighlight %}

이런 케이스에서는 Kotlin에서는 다음과 같이 쓰는 것이 가능합니다.

{% highlight kotlin %}
val result: Boolean = user?.let { write(it) } ?: false
{% endhighlight %}

let의 정의와 구현은 다음과 같이 되어있습니다.

{% highlight kotlin %}
public inline fun <T, R> T.let(f: (T) -> R): R = f(this)
{% endhighlight %}

이것은 모든 타입 T에서 정의된 확장 메소드로 인자로 클로져를 하나 가지고 있습니다. 그리고 그 클로져에 메소드의 리시버가 전달되어 불러질 것이고 그 자체가 let 자체의 값이 됩니다.

위의 예시에는 `?.`가 있으므로 let이 실행되는 것은 `User?`가 null이 아닌 경우입니다. it은 클로져의 암시적인 인자이므로 it은 `User`가 되는 것입니다. 그리고 write의 반환 값은 let의 반환 값이므로 기대했던대로 동작할 것입니다.

Swift의 경우에는 Optional 자체에 정의된 `flatMap` 메소드를 쓸 수 있습니다.

{% highlight swift %}
let result: Bool = user.flatMap { write($0) } ?? false
{% endhighlight %}

이 경우에는 Optional 자체의 메소드임에도 불구하고 `?.`가 아닌 `.`이 됩니다.

### 기본적인 콜백 함수

기본적인 콜백 함수가 쓸 수 있습니다. 클로져가 `{}`로 표현되기 때문에 쉽게 쓸 수 있습니다.

{% highlight kotlin %}
fun main(args: Array<String>) {
    val a = (0..10)
        .filter { it % 2 == 0 }
        .map { it * it }
        .fold("") { s, i -> 
            (if (s != "") s + "_"  else "") + i.toString()
        }

    println(a) // 0_4_16_36_64_100가 나온다.
}
{% endhighlight %}

Swift도 비슷한 느낌으로 작성할 수 있습니다.

{% highlight swift %}
let a = (0...10)
    .filter { $0 % 2 == 0 }
    .map { $0 * $0 }
    .reduce("") {
        let s = $0 != "" ? $0 + "_" : ""
        return s + String($1)
    }

print(a) // 0_4_16_36_64_100가 나온다.
{% endhighlight %}

Java라면 이렇게 나오겠죠.

{% highlight java %}
String a = IntStream.rangeClosed(0, 10)
    .mapToObj(i -> Integer.valueOf(i))
    .filter(i -> i % 2 == 0)
    .map(i -> i * i)
    .reduce("", (s, i) -> 
        (!s.equals("") ? s + "_" : "") + i
    , (s1, s2) -> s1 + s2);

print(a);
{% endhighlight %}

Kotlin은 Swift의 클로져 리터럴과 함수를 호출할 때의 표기법이 비슷합니다. Swift 버전의 reduce의 내부는 한 줄로 쓰고 싶었습니다만 타입 추론에 타임아웃이 걸려서 컴파일하지 못했기 때문에 let으로 나눴습니다. Kotlin에서는 클로져의 암시적 인자는 인자가 1개일 때만 `it`을 쓸 수 있습니다. 복수일 때는 인자명이 필요합니다. Swift에서는 `$0`, `$1`, `$2`... 이런 식으로 쓰입니다. 또 Kotlin에서는 삼항연산자가 없지만 if문을 이용해서 쓸 수 있습니다.

### 문자열 안에서의 변수 접근

Kotlin에서는 문자열 안에서 `$`로 변수를, `${}`로 식을 호출할 수 있습니다.

{% highlight kotlin %}
fun hoge(i: Int, user: User) {
    println("i is $i, user name is ${user.name}")
}
{% endhighlight %}

`$i` 부분이 변수가, `${user.name}` 부분이 식을 표시합니다. Swift에서는 `\()`로 쓸 수 있죠.

{% highlight swift %}
func hoge(i: Int, user: User) {
    print("i is \(i), user name is \(user.name)")
}
{% endhighlight %}

Java에서는 이런 기능에 대한 문법이 없으니 아래와 같이 되겠죠.

{% highlight java %}
void hoge(int i, User user) {
    print("i is " + i + ", user name is " + user.name);
}

void hoge2(int i, User user) {
    printf("i is %d, user name is %s", i, user.name);
}
{% endhighlight %}

### Java의 단일 추상 메소드(SAM) 변환

Java에서는 Java8이 나오면서 람다식과 단일 추상 메소드를 가지는 함수형 인터페이스라는 큰 기능이 추가되었습니다. 이것은 단일 메소드를 가지고 있는 인터페이스에서 람다식을 쓸 수 있게 됬다는 것을 의미합니다.

예를 들면, 아래가 Java7의 코드입니다. 안드로이드에서 자주 볼 수 있는 버튼의 클릭 핸들러를 설정하는 코드입니다.

{% highlight java %}
button.setOnClickListener(new View.OnClickListener {
    @Override
    void onClick(View view) {
        println("clicked");
    }
});
{% endhighlight %}

이게 Java8이라면 다음과 같이 표현할 수 있게 됩니다.

{% highlight java %}
button.setOnClickListener(view -> {
    println("clicked");
});
{% endhighlight %}

이는 Java8에서 람다식을 도입함에 있어 Java7 이전에 있었던 코드의 낭비하거나 수정하지 않고도 람다식을 이용해 보다 쾌적하게 쓸 수 있게 되었습니다.

이렇게 람다식으로 자동 변환될 수 있는 인터페이스는 단일 메소드여야만 합니다.
그래서 이것을 단일 추상 메소드(Single Abstract Method), 줄여서 SAM이라고 칭하며 이 변환을 SAM 변환이라고 합니다.

Kotlin에서는 Java8과 마찬가지로 이 기능을 탑재하고 있습니다. 이 기능은 Java와 연계해서 Java 라이브러리를 사용하는데 없으면 안되는 중요한 기능 중 하나입니다.

##### 역주

'SAM 변환'이라는 말이 낯설게 느껴질 수 있는데, 이는 한국에서 잘 쓰이지 않기 때문입니다. 위에서 설명한 단일 추상 메소드를 가지고 있는 인터페이스에 대해 람다식을 쓸 수 있는 기능은 Java8의 중요한 신기능입니다. Kotlin에서는 이 기능을 Java8 이전인 Java6, 7에서도 쓸 수 있습니다. 이는 Android가 아직 Java8을 공식적으로 지원하지 않기 때문에 Kotlin이 주목을 받는 이유 중 하나이기도 합니다. Android를 Java로 개발할 때에는 대안으로 RetroLambda라고 하는, 컴파일 시 바이트코드를 수정해서 쓸 수 있게 하는 라이브러리가 존재합니다.

위에 예시는 Kotlin에서는 아래와 같이 쓸 수 있습니다.

{% highlight kotlin %}
button.setOnClickListener { view ->
    println("clicked")
}
{% endhighlight %}

쓰기 쉬워 좋네요. 위의 예에서는 인수가 클로져 한개일 뿐이라 함수 호출 괄호`()`를 생략했습니다.

### 확장 메소드

Kotlin에서는 기존 클래스에 대해 메소드를 추가해 확장하는 것이 가능합니다.

{% highlight kotlin %}
fun Int.square(): Int = this * this
fun <T> List<T>.evens(): List<T> = withIndex().filter { it.index % 2 == 0 }.map { it.value }
fun List<Int>.squareEvens(): List<Int> = evens().map { it.square() }

fun main(args: Array<String>) {
    val a = 3
    println(a.square()) // 9라고 출력

    val b = listOf("a", "b", "c", "d", "e")
    println(b.evens()) // [a, c, e]라고 출력

    val c = listOf(10, 20, 30, 40, 50)
    println(c.squareEvens()) // [100, 900, 2500]라고 출력
}
{% endhighlight %}

제너릭 자료형의 확장 메소드에 관해서는 T 모두에 대한 것과 특정 T에 대한 정의가 가능합니다. 함수의 본문은 `=` 스타일로 써봤습니다.

Swift에서는 다음과 같이 쓸 수 있겠습니다.

{% highlight swift %}
extension IntegerType {
    func square()-> Self {
        return self * self
    }
}
extension Array {
    func evens()-> Array<Element> {
        return enumerate().filter { $0.index % 2 == 0 }.map { $0.element }
    }
}
extension Array where Element: IntegerType {
    func squareEvens()-> Array<Element> {
        return evens().map { $0.square() }
    }
}

func main() {
    let a = 3
    print(a.square()) // 9라고 출력

    let b = ["a", "b", "c", "d", "e"]
    print(b.evens()) // ["a", "c", "e"]라고 출력

    let c = [10, 20, 30, 40, 50]
    print(c.squareEvens()) // [100, 900, 2500]라고 출력
}

main()
{% endhighlight %}

Element에 대한 제약은 프로토콜에 필요가 있으므로 `Int`로 쓸 수 없어서 그 대신 `IntegerType`으로 되어있습니다. 이유를 잘 모르겠습니다.

Kotlin도 Swift도 둘 다 프로퍼티를 추가하는 것이 가능합니다. 이식했을 때는 `withIndex`와 `enumerate`가 대응되어서 기뻤습니다.

Java에는 확장 메소드라는 개념이 없기 때문에 첫 번째 인수에 this를 가지는 정적 메소드로 구현해야되겠죠.

{% highlight java %}
public class Main {
    public static void print(String str) {
        System.out.println(str);
    }

    public static int intSquare(int x) { return x * x; }

    public static <T> List<T> listEvens(List<T> list) {
        return IntStream.range(0, list.size())
            .filter(i -> i % 2 == 0)
            .mapToObj(i -> list.get(i))
            .collect(Collectors.toList());
    }

    public static List<Integer> intListSquareEvens(List<Integer> list) {
        return listEvens(list).stream()
            .map(i -> intSquare(i))
            .collect(Collectors.toList());
    }

    public static void main (String[] args) throws java.lang.Exception {
        int a = 3;
        print("" + intSquare(a)); // 9라고 출력

        List<String> b = listEvens(Arrays.asList("a", "b", "c", "d", "e"));
        print("" + b); // [a, c, e]라고 출력

        List<Integer> c = intListSquareEvens(Arrays.asList(10, 20, 30, 40, 50));
        print("" + c); // [100, 900, 2500]라고 출력
    }
}
{% endhighlight %}

이 방식이 괴로운 것은 충돌을 피하고자 메소드 이름에 접두사가 필요하다는 점과 호출할 때 `f(g(h(x)))`라는 형식이 되므로 나중에 적용하는 함수일수록 앞에 오는 등의 문제가 있습니다. 특히 이식을 할 때에는 원래 메소드 체인의 형태로 되어있다면 기술 순서가 완전히 거꾸로 되어버리기 때문에 매우 번거로운 작업이 됩니다. 개인적으로는 이 부분이 가독성도 떨어트린다고 생각합니다.

또, 이 코드는 `withIndex`에 대응하는 방법을 몰랐기 때문에 얼버무려 쓴 코드입니다.

### 오퍼레이터 오버로드

Kotlin에서는 오퍼레이터 오버로드라는 기능이 존재합니다. 하지만 직접 메소드 이름에 연산자를 표기하는 Swift와 C++과는 달리 Kotlin에서는 미리 정해진 연산자에 해당하는 이름의 메소드를 operator 키워드와 함께 구현합니다. 스스로 연산자를 추가할 수는 없지만 인수가 하나인 메소드를 삽입할 수 있는 기능이 있으므로 키워드로 연산자를 추가하는 것은 할 수 있습니다.

{% highlight kotlin %}
data class Vector2(val x: Double, val y: Double) {
    operator fun plus(o: Vector2): Vector2 = Vector2(x + o.x, y + o.y)
    fun dot(o: Vector2): Double = x * o.x + y * o.y
    override fun toString(): String = "($x, $y)"
}

operator fun Double.times(o: Vector2): Vector2 = Vector2(this * o.x, this * o.y)

fun main(args: Array<String>) {
    val a = Vector2(1.0, 2.0) + Vector2(3.0, 4.0)
    println(a) // (4.0, 6.0)라고 출력

    val b = 3.0 * Vector2(0.0, 1.0)
    println(b) // (0.0, 3.0)라고 출력

    val c = Vector2(2.0, 0.0) dot Vector2(2.0, 3.0)
    println(c) // 4.0라고 출력
}
{% endhighlight %}

덧셈은 메소드로 곱셈은 Double 자료형의 확장 메소드로 썼습니다. `dot`은 보통의 방법입니다만 중간에 저렇게 사용할 수 있습니다.
데이터 클래스와 기본 생성자의 기능도 쓰고 있습니다.

Swift로도 써봤습니다.

{% highlight swift %}
class Vector2: CustomStringConvertible {
    let x: Double
    let y: Double
    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    var description: String {
        return "(\(x), \(y))"
    }
}

func +(l: Vector2, r: Vector2)-> Vector2 {
    return Vector2(l.x + r.x, l.y + r.y)
}
func *(l: Double, r: Vector2)-> Vector2 {
    return Vector2(l * r.x, l * r.y)
}

infix operator ● { 
    associativity left
    precedence 140 
}

func ●(l: Vector2, r: Vector2)-> Double {
    return l.x * r.x + l.y * r.y
}

func main() {
    let a = Vector2(1.0, 2.0) + Vector2(3.0, 4.0)
    print(a) // (4.0, 6.0)라고 출력

    let b = 3.0 * Vector2(0.0, 1.0)
    print(b) // (0.0, 3.0)라고 출력

    let c = Vector2(2.0, 0.0) ● Vector2(2.0, 3.0)
    print(c) // 4.0라고 출력
}

main()
{% endhighlight %}

●은 유니코드 문자입니다. 이번 예시에서는 Swift의 기능을 이용해 이 마크를 연산자로 정의했습니다.

Kotlin은 연산자를 만드는 것은 불가능하기 때문에 Swift에서 정의된 독자 연산자의 이식은 메소드로 합니다.
하지만, 연산자 우선 순위까지 이식할 수 없기 때문에 소괄호`()`를 붙여 나갈 필요가 있겠죠.

Java에서는 이런 기능을 쓸 수 없기 때문에 확장 메소드와 마찬가지로 이식할 때 매우 불편합니다.

### 프로퍼티

Kotlin의 필드같은 것들은 모두 프로퍼티입니다.
상수는 val, 변수는 var로 정의하며, val에는 getter를, var에는 getter와 setter를 정의할 수 있습니다.
getter와 setter를 구현하기 위한 지원 필드가 자동으로 정의되며 field라고 하는 키워드로 액세스할 수 있습니다.

{% highlight kotlin %}
class User {
    val id: Int
    var familyName: String = "야마다"
    var firstName: String = "타로"

    val fullName: String
        get() = "$familyName $firstName"
    var died: Boolean = false
        get() { return field }
        set(value) {
            field = value
            if (value) {
                println("${fullName}는 죽어버렸다...")
            }
        }
    constructor(id: Int) {
        this.id = id
    }
}
fun main(args: Array<String>) {
    val u = User(3)
    u.familyName = "사이토"
    u.died = true // 사이토 타로는 죽어버렸다... 라고 표시됩니다.
}
{% endhighlight %}

위의 예에서 `id`는 상수이기 때문에 getter가 자동 생성되었고, `familyName`, `firstName`은 변수이기 때문에 getter와 setter가 자동으로 생성된 것을 볼 수 있습니다.
`fullName`은 getter를 직접 만들어서 다른 프로퍼티로부터 동적으로 가져올 수 있도록 했습니다. `died`는 getter와 setter를 직접 만들어서 지원 필드를 사용했습니다.

Swift에서도 필드와 같은 것은 프로퍼티입니다. getter, setter 뿐만이 아니라 `willSet`과 `didSet`같은 것들도 정의할 수 있습니다. 하지만 Kotlin처럼 지원 필드는 자동으로 정의되지 않습니다.

Kotlin에서는 `didSet`과 같은 언어 기능은 존재하지 않기 때문에 이식은 setter에서 에뮬레이트하는 방식을 이용합니다.

{% highlight swift %}
class User {
    let id: Int
    var familyName: String = "yamada"
    var firstName: String = "taro"

    var fullName: String {
        get { return "\(familyName) \(firstName)" }
    }
    var died: Bool = false {
        didSet {
            if died {
                print("\(fullName)는 죽어버렸다...")
            }
        }
    }
    init(_ id: Int) {
        self.id = id
    }
}

func main() {
    let u = User(3)
    u.familyName = "saito"
    u.died = true // saito taro는 죽어버렸다... 라고 표시됩니다.
}

main()
{% endhighlight %}

Java에서는 필드와 프로퍼티는 명확하게 구분되어있으며 메소드로 직접 getter과 setter를 구현한 것을 프로퍼티라고 부릅니다.

이 부분이 이식할 때 귀찮은 일이 되어버립니다. Swift로 쓰인 다음 클래스가 있다고 생각해봅시다.

{% highlight swift %}
class User {
    var died: Bool = false
}

func hoge(u: User) {
    u.died = true
}
{% endhighlight %}

이것을 Java의 필드로 이식해보겠습니다.

{% highlight java %}
class User {
    boolean died = false;
}

void hoge(User u) {
    u.died = true
}
{% endhighlight %}

그 뒤에 Swift 코드가 이렇게 변했다고 칩시다.

{% highlight swift %}
class User {
    var died: Bool = false
    didSet {
        println("죽어버렸다!")
    }
}
{% endhighlight %}

이런 경우 Java에서는 다음과 같이 수정해야합니다.

{% highlight java %}
class User {
    boolean died = false;
    boolean getDied() { return died; }
    void setDied(boolean value) { 
        died = value;
        println("죽어버렸다!");
    }
}

void hoge(User u) {
    u.setDied(true);
}
{% endhighlight %}

getter와 setter를 직접 구현해야 하는 것은 둘째치고, 필드에 대입하고 있는 부분을 setter를 호출할 때 구현해야 할 필요가 있습니다.

이것은 여러 부분에 있습니다만 원래 이식하는 곳에서는 diff가 발생하지 않기 때문에 놓칠 위험이 큽니다. 간과해버렸다간 버그가 나며 심지어 컴파일했을 때 알 수도 없습니다.

만약 10번 있는 대입에 한 곳만의 지원을 잊어버린다면 이건 매우 귀찮은 버그가 될 것입니다. 그러므로 프로퍼티가 있는 언어에서 이식한다면 프로퍼티가 있는 언어로 이식하는게 바람직합니다.

### Java 프로퍼티 접근자의 프로퍼티화

Java에서 필드 `name`에 대해 `name`이라는 프로퍼티를 만들 때는 getter로 `String getName ()`과 setter로 `void setName(String name)`을 정의합니다.
그리고 호출 시, 아래와 같이 함수 호출의 형태를 취합니다.

{% highlight java %}
// 읽기
String name = user.getName();
// 쓰기
user.setName(newName);
{% endhighlight %}

하지만 Kotlin의 경우에는 프로퍼티 `name`에 대해서 호출할 때 함수의 형태를 띄지 않습니다.

{% highlight kotlin %}
// 읽기
val name = user.name
// 쓰기
user.name = newName
{% endhighlight %}

함수 호출의 형태는 아닙니다만 name에 대한 getter와 setter가 동작하게 됩니다.

Kotlin에서 Java 메소드를 호출할 때 이러한 `getXxxx()`와 `setXxxx(value)`를 Kotlin의 프로퍼티 `xxxx`를 취급할 때 엑세스할 수 있습니다.
예를 들어, 아래코드는 안드로이드에서 버튼을 보이지 않게 만드는 코드입니다.

{% highlight kotlin %}
button.visibility = View.INVISIBLE
{% endhighlight %}

Android SDK는 Java로 작성되었으므로 원래는 `setVisibility()`를 호출하는게 맞지만, Kotlin에서는 마치 `visibility`라는 프로퍼티에 접근하는 것처럼 사용할 수 있습니다.

### Delegated Property

Delegated Property는 Kotlin의 재미있는 기능입니다. 프로퍼티의 getter와 setter의 구현을 다른 객체에 넘기는 것이 가능합니다.

#### Lazy

예로 Lazy를 들어보겠습니다.

{% highlight kotlin %}
val fullName: String by lazy {
    familyName + " " + firstName
}
{% endhighlight %}

`fullName`은 상수이지만, 처음 getter가 호출되었을 때 lazy에 전달하는 클로져가 실행되고 그 결과가 반환됩니다. 두번째 이후부터 getter 호출에서는 첫번째 결과가 저장됩니다. 만약 이것을 Java로 구현하고자 할 때는, getter에서 if문을 작성해야만 합니다. 이러한 일반적으로 중복되는 코드를 쓸 필요가 없습니다.

Swift에서도 `lazy`라는 키워드가 있고 동일한 기능을 제공하는 언어 기능이 있습니다. 그러나 Kotlin이 흥미로운 점은 lazy가 특별한 언어 기능이 아니라 `by`만이 언어 기능으로, lazy는 그저 [클로져를 인수로 취하는 표준 라이브러리 함수](http://kotlinlang.org/api/latest/jvm/stdlib/kotlin/lazy.html)인 것입니다. 이 함수가 반환하는 객체가 실제 프로퍼티의 getter와 setter를 처리합니다.

#### notNull

**이 문단은 오래되었습니다. M13에서부터는 lateinit을 사용하는 편이 더 좋다고 생각됩니다.**

또 한 가지, 흥미로운 델리게이트를 소개해보곘습니다. 

{% highlight kotlin %}
var name: String by Delegates.notNull()
{% endhighlight %}

이것은 한번 설정되지 않은 상태에서 getter가 호출될 경우 예외가 생겨 크래시가 납니다. 한번 설정된 이후에는 getter가 일반적으로 값을 읽어올 수 있습니다.
Swift에서 이와 비슷한 형태를 갖는 것은 느낌표`!` 형태입니다. 정확하게 말하자면 `Implicitly Unwrapped Optional`이라고 말합니다.

{% highlight swift %}
var name: String!
{% endhighlight %}

이것은 초기 상태가 nil로 nil의 상태로 읽었을 때는 크래시가 나지만 값이 들어있을 때는 보통과 똑같이 사용할 수 있습니다.
Kotlin과의 미묘한 차이는 Kotlin은 notNull에 null을 넣을 수 없지만 Swift의 `!`에는 nil을 넣을 수 있다는 것이겠네요.
Swift의 `!`는 어디까지나 Optional이라는 것이군요.

그러나 대부분의 경우 일부러 nil을 넣는 일을 하지 않기 때문에 이식하는데는 크게 문제가 없습니다.
보통 그런 일은 Optional에다가 하는 것이 더 바람직하니까요.

이 경우도 Swift에서는 언어 기능이지만 Kotlin에서는 표준 라이브러리가 제공하는 구현입니다.
재미있습니다.

#### KotterKnife

Android 앱을 만들 때 제일 많은 부분이 View의 바인딩인데, ButterKnife를 만든 사람이 [KotterKnife](https://github.com/JakeWharton/kotterknife)라고 하는 Kotlin 버전의 ButterKnife를 제공하고 있습니다.

##### 역주

ButterKnife를 만든 사람은 Square라는 결제 관련 POS 시스템을 만드는 회사에 있는 Jake Wharton이라는 분입니다. ButterKnife는 리소스나 뷰의 바인딩을 쉽게 도와주는 라이브러리로, 안드로이드 개발자들에게 Jake Wharton은 예전부터 다양한 라이브러리로 유명했었습니다.

{% highlight kotlin %}
public class PersonView(context: Context, attrs: AttributeSet?) : LinearLayout(context, attrs) {
  val firstName: TextView by bindView(R.id.first_name)
  val lastName: TextView by bindView(R.id.last_name)

  // Optional binding.
  val details: TextView? by bindOptionalView(R.id.details)

  // List binding.
  val nameViews: List<TextView> by bindViews(R.id.first_name, R.id.last_name)

  // List binding with optional items being omitted.
  val nameViews: List<TextView> by bindOptionalViews(R.id.first_name, R.id.middle_name, R.id.last_name)
}
{% endhighlight %}

`@IBOutlet`이나 `!`를 사용한 iOS 개발과, 어노테이션과 리플렉션으로 구현된 Android의 ButterKnife보다 이 방식이 깔끔하고 바람직하다고 생각됩니다.
또한 빌드에 개입하는 것으로 확장 메소드를 구현해주고, 프로퍼티 정의조차 불필요한 플러그인이 있습니다.

나는 이런 언어기능이 바람직하다고 생각합니다.

### lateinit

프로퍼티에 대한 한정자로 `lateinit`을 사용하면, 초기값이 불필요한 Optional이 아닌 변수를 정의할 수 있습니다.

{% highlight kotlin %}
class User {
    lateinit var name: String
}
{% endhighlight %}

lateinit으로 지정되어있는 변수는 쓰기 전에 읽으면 크래시가 납니다. Swift의 `!`처럼 사용할 수 있습니다.

#### Delegate.notNull과의 차이

Delegate.notNull과의 차이는 잘 모르겠습니다. 문서에 따르면 lateinit은 자연스럽게 필드명을 만들어서 DI 도구와의 궁합이 좋다고 쓰여있습니다.
아마도 자동생성 바이트코드나 리플렉션에 대한 부분이 아닐까 생각합니다.

하지만 Kotlin 코드 만의 세계에서 보면 그 차이는 중요하지 않습니다.

유일하게 찾아낸 것은 lateinit는 상수에는 사용하지 못하고 변수에만 사용할 수 있습니다. notNull는 상수에도 사용할 수 있습니다.

그러나 notNull가 상수에 사용하는 것은 충돌 가능성만 있고 혜택은 전혀 없기 때문에 상수에서의 사용이 금지 된 lateinit 쪽이 안전하고 약간 우수하다고 생각합니다.

위에서 말한 이유로 notNull이 언어 기능에 의존하지 않는 매력이지만 lateinit을 쓰는 편이 더 바람직해보입니다.

### 제네릭과 Declaration Site Variance

Kotlin은 제네릭을 지원하고 있습니다. 제네릭형 매개변수의 variance에 대해서는 Declaration Site Variance라고 칭하고 있습니다.

{% highlight kotlin %}
open class Animal
class Cat: Animal()

class Box<out T>(val value: T) {
    override fun toString(): String = "Box($value)"
}

fun main(args: Array<String>) {
    val a: Box<Animal>
    val b: Box<Cat> = Box(Cat())
    a = b
    println(a) // Box(Cat@xxxxxxxx)로 표시
}
{% endhighlight %}

Variance가 작동하고 있으므로 Box의 값을 Box의 변수에 대입할 수 있습니다.

Declaration Site라고 하는 것은 선언 시에 지정하는 것으로 Box의 변수형 파라미터 T를 쓰는 그 자리에서 `out T`라고 기술함으로써 Box가 T에 대해 covariance라고 선언하고 있습니다.
이 out을 지우면 컴파일 에러가 발생합니다. Swift도 Declaration Site지만, Java는 Use Site입니다.

Java로 위의 예를 쓰면 다음과 같습니다.

{% highlight java %}
class Animal {}
class Cat extends Animal {}

class Box<T> {
    final T value;
    Box(T value) {
        this.value = value;
    }
    public String toString() { return "Box(" + value.toString() + ")"; }
}

public class Main {
    public static void print(String str) {
        System.out.println(str);
    }
    
    public static void main (String[] args) throws java.lang.Exception {
        final Box< ? extends Animal> a;
        final Box<Cat> b = new Box<Cat>(new Cat());
        a = b;
        print(a.toString()); // Box(Cat@xxxxxxxx)라고 출력된다.
    }
}
{% endhighlight %}

Box 자체의 정의에 대한 Variance에 대해 적지 않고 `a`라는 로컬 변수를 정의할 때의 형태를 꺽쇠 기호`<>`로 설명하고 있습니다. 그 외 함수 인수의 정의에서 꺽쇠 기호가 나옵니다.

Declaration Site와 Use Site의 좋고 나쁨에 대해서는 여기까지만 이야기하겠습니다. 저는 Declaration Site 쪽을 선호하기 때문에 Kotlin을 선호합니다. 그 외 Swift나 C#, Go 또한 Declaration Site입니다.

Swift도 동일하기 때문에 Swift로부터 이식하기 쉽습니다. 그러나 Swift에서 Java로의 이식은 꽤나 힘듭니다. 선언은 한 곳에서 함에도 불구하고 사용 부분(함수 인수나 지역 변수)은 많이 있어서 이론적으로는 그것을 `? extends T`나 `? super T`로 쓰지 않으면 올바르게 이식되지 않습니다.

Variance를 버리고 컴파일 에러가 나는 곳만을 고치는 일이 생길 수도 있습니다.

### 클로져와 전역 탈출

Kotlin의 클로져는 생각지도 못한 기능을 가지고 있습니다. 다음 코드는 다른 언어에 익숙한 사람에게는 의미불명으로 보입니다.
또한 `forEach`는 클로져를 하나의 인수로 취하여 리시버의 요소 하나하나에 대하여 클로져를 호출합니다.

{% highlight kotlin %}
fun hasZeros(ints: List<Int>): Boolean {
  ints.forEach {
    if (it == 0) { return true }
  }
  return false
}
{% endhighlight %}

사실 이 코드는 `forEach`에 쓰여진 `return true`가 그 클로져 자신이 아닌 `fun hasZeros()`를 탈출하는 것입니다. 원래 Kotlin의 클로져 안에는 return을 쓸 수 없습니다. 클로져의 실행 결과는 클로져 코드 마지막의 식의 값입니다.

예외적으로 인라인된 콜백 함수에서는 `return`을 쓸 수 있고 그 경우에는 return을 호출한 곳에서부터 가장 가까운 함수를 탈출하게 됩니다.

forEach의 구현은 다음과 같습니다.

{% highlight kotlin %}
public inline fun <T> Iterable<T>.forEach(operation: (T) -> Unit): Unit {
    for (element in this) operation(element)
}
{% endhighlight %}

이 `fun` 앞에 있는 `inline`이 포인트입니다. 이것이 붙어있으면 함수가 인라인이라는 것을 뜻하는데, 이 함수를 호출하는 곳에 이 함수의 내용이 쓰여지는 것과 같습니다. 즉 위의 예시는 아래와 같이 해석된다고 보면 됩니다.

{% highlight kotlin %}
fun hasZeros(ints: List<Int>): Boolean {
    for (i in ints) {
        if (i == 0) { return true }
    }

    return false
}
{% endhighlight %}

이걸로 왜 전역 탈출이 가능하게 되었는지 알 수 있었습니다. 또한 `inline`의 지정은 무턱대고 있는 것이 아닙니다. 인라인할 수 없는 함수에 붙어있을 경우에는 컴파일 에러가 납니다.

그래서 이 전역 탈출이라는 기능은 위험한 냄새가 납니다. 올바르게 사용할 때만 구현해서 이용할 수 있으며 그렇지 않을 경우에는 컴파일 에러가 나기 때문에 안전합니다.

이게 가능하기 때문에 `forEach`도 그렇습니다만 콜백 함수를 정의하여 제어 구문을 자작할 수 있는 효과가 있습니다.

예를 들면 `run`이라고 하는 표준 함수가 있습니다.

{% highlight kotlin %}
public inline fun <R> run(f: () -> R): R = f()
{% endhighlight %}

인수로 주어진 클로져만을 실행하기 위한 함수이지만, 이것은 로컬 스코프를 만드는데 사용할 수 있습니다.

{% highlight swift %}
fun setup() {
    run {
        val x = 3
        if (!createPoint(x)) { return }
    }
    run {
        val x = "taro"
        if (!createUser(x)) { return }
    }
    println("ok!")
}
{% endhighlight %}

위의 예에서는 2개의 x는 각각 다른 클로져의 지역 변수이므로 충돌하지 않습니다.
그리고 `createPoint`가 실패했을 때 `setup` 자체를 중단하고 있습니다.

Swift에서 똑같이 콜백 함수를 사용하고자 하면 그 안에 return을 쓸 수 없게 되기 때문에 `for in`이나 `if true {}`를 사용하지 않을 수 없습니다.

반대로 말하면 이런 것들을 사용하면 구문과 같은 것들을 만들 수 있다는 뜻이 됩니다.
run에서는 사실 또 정의가 있고 그것을 사용하면 이런 코드를 만들 수 있습니다.

{% highlight kotlin %}
class User {
    var name: String = ""
    var age: Int = 0
}

fun hoge(user: User) {
    user.run {
        name = makeUserName() ?: return
        age = 3
    }
}
{% endhighlight %}

`run`의 안에서 액세스 되어있는 `name`이나 `age`는 `user`의 프로퍼티입니다.
이 클로져의 안은 User의 메소드를 실행할 때와 같은 this 스코프입니다. 그리고 당연한 이야기지만 그 안에서도 전역 탈출을 쓸 수 있습니다.

이것의 구현은 아래와 같습니다.

{% highlight kotlin %}
public inline fun <T, R> T.run(f: T.() -> R): R = f()
{% endhighlight %}

모든 타입 T에 대한 확장 메소드 run으로 정의되어 있으며 인수의 클로져의 자료형은 T의 메소드, 즉 리시버로 T 자료형의 인스턴스를 받도록 되어있습니다.
본체의 `f()`는 확장 메소드의 정의 중이기 때문에 `this.f()`의 축약형입니다.

클로져의 형태가 run의 인수에 따라서 T 자료형의 메소드의 형태로 해결하고 있으므로 콜백 메소드 안에서 name과 age가 `this.` 없이 접근할 수 있는 것입니다.

이 클로져의 메소드 형태에 대한 해결책이 정말 강력합니다. 더 복잡한 응용 예는 다음과 같습니다.

{% highlight kotlin %}
fun result(args: Array<String>) =
  html {
    head {
      title {+"XML encoding with Kotlin"}
    }
    body {
      h1 {+"XML encoding with Kotlin"}
      p  {+"this format can be used as an alternative markup to XML"}

      // an element with attributes and text content
      a(href = "http://kotlinlang.org") {+"Kotlin"}

      // mixed content
      p {
        +"This is some"
        b {+"mixed"}
        +"text. For more see the"
        a(href = "http://kotlinlang.org") {+"Kotlin"}
        +"project"
      }
      p {+"some text"}

      // content generated by
      p {
        for (arg in args)
          +arg
      }
    }
  }
{% endhighlight %}

이걸 보면 HTML을 간단한 문법으로 쓰고 있는 것 같아도 이건 엄연히 Kotlin 코드입니다. 게다가 body 태그는 html 태그에 쓰기 같은 것들이 정적 타이핑 검사되고 있습니다.

[자세한 내용은 문서를 읽어보십시오.](http://kotlinlang.org/docs/reference/type-safe-builders.html)

그런데 전역이 아닌 클로져를 중단하고 싶은 로컬한 return을 쓰고 싶을 때가 있습니다. 그런 경우에는 또 다른 클로져 표기법을 쓸 수 있습니다.

{% highlight kotlin %}
listOf(1,2,3,4).forEach(fun(i) {
    if (i % 2 == 0) return
    print(i)    
})
// 13이 출력됩니다.
{% endhighlight %}

`fun` 표기가 있으면 인라인과는 전혀 관계 없이 클로져에서 항상 return을 사용할 수 있습니다. 그리고 로컬한 return이 됩니다. 아까 말했듯이 return을 호출한 곳에서부터 가장 가까운 함수를 탈출한다는 규칙에도 맞습니다.

### 기본 생성자

Kotlin에서는 생성자를 다중 정의할 수 있습니다. 그리고 특별한 기본 생성자는 생성자를 하나만 만들 수 있습니다.
이 생성자가 있는 경우에는 다른 생성자는 결국 기본 생성자를 호출할 수밖에 없습니다.

그리고 기본 생성자는 인수 정의와 동시에 속성 정의를 할 수 있는데, 이 기능이 꽤 유용합니다. 키워드를 한 번 쓰는 것만으로 되니까요.

{% highlight kotlin %}
class Person(val name: String, val age: Int, val height: Double) {
    init {
        // 기본 생성자의 본문입니다.
        print("1")
    }

    constructor(name: String): this(name, 20, 170.0) {
        // 2차 생성자의 본문입니다.
        print("2")
    }

    constructor(): this("saito") {
        // 2차 생성자의 또 다른 하나입니다. 다른 2차 생성자를 호출하고 있습니다.
        print("3")
    }
}

fun main(args: Array<String>) {
    Person("yamada", 19, 160.0) // 1이 출력됩니다.
    println()
    Person("tanaka") // 12가 출력됩니다.
    println()
    Person() // 123이 출력됩니다.
    println()
}
{% endhighlight %}

기본 생성자의 인수로 있는 상수가 프로퍼티 정의를 지정합니다.

기본 생성자를 정의하지 않는 것 또한 가능합니다.

Swift의 경우에는 지정 이니셜라이저(Designated Initializer)와 편의 이니셜라이저(Convience Initializer)가 있습니다.
Kotlin과 같이, 편의 이니셜라이저는 지정 이니셜라이저를 호출할 필요가 있습니다.
Kotlin하고는 다르게 지정 이니셜라이저를 다중 정의할 수도 있습니다.

생성자에서 프로퍼티 정의 구문이 없기 때문에 프로퍼티, 생성자의 인수, 생성자의 본문에서 왼쪽 값, 오른쪽 값으로 총 4번 동일한 키워드를 쓸 수밖에 없습니다.

{% highlight swift %}
class Person {
    let name: String
    let age: Int
    let height: Double

    init(_ name: String, _ age: Int, _ height: Double) {
        // 기본 생성자 1
        self.name = name
        self.age = age
        self.height = height
    }
    init(_ name: String, _ age: Int, _ height: Int) {
        // 기본 생성자 2
        self.name = name
        self.age = age
        self.height = Double(height)
    }
    convenience init(_ name: String) {
        // 2차 생성자 1
        self.init(name, 20, 170.0)
    }
    convenience init() {
        // 2차 생성자 2
        self.init("saito")
    }
}
{% endhighlight %}

이식의 관점에서 보면 Swift에서 지정 이니셜라이저가 다수 있어도 프로퍼티를 모두 채울 기본 생성자를 만들고 나머지 지정 이니셜라이저와 편의 이니셜라이저를 보조로 쓰면 크게 문제되지 않는다고 생각됩니다.

Java의 경우 Swift와 거의 비슷한 규칙이지만 convenience같은 키워드는 존재하지 않네요.

### 특별한 자료형

Kotlin만이 가지고 있는 특별한 자료형에 대해 소개해보고자 합니다.

#### Any

Any는 모든 자료형를 취할 수 있는 자료형입니다. 하지만 Optional 자료형은 취할 수 없습니다.
제네릭형의 매개변수를 정의할 때 null을 제거할 때 쓰입니다.

{% highlight kotlin %}
class NonNullBox<T: Any>
class NullableBox<T>
{% endhighlight %}

`NonNullBox`에는 Optional 자료형이 들어갈 수 없지만 `NullableBox`는 들어갈 수 있습니다.

#### Unit

Unit은 값이 하나 밖에 없고, 다른 형식으로 독립한 자료형입니다.
C의 void와 Swift의 Void 등에 대응하며, 함수 반환 값의 자료형을 생략했을 때는 Unit이 반환됩니다.
Unit 자료형의 값은 Unit입니다.

{% highlight kotlin %}
fun a(): Unit {
    return Unit
}
fun b(): Unit {
    return
}
fun c() { }
{% endhighlight %}

여기서 `a`, `b`, `c`는 모두 같은 의미입니다.

역으로 Kotlin엔 void라는 개념이 존재하지 않습니다.

#### Nothing

Nothing은 값이 존재하지 않고 다른 모든 타입에 할당할 수 있는 자료형입니다. Any는 모든 자료형를 대입할 수 있지만 그것과 반대로 되어있습니다.
값이 존재하지 않기 때문에 함수의 반환 값으로 지정하면 들어가면 절대로 탈출하지 않는 함수가 됩니다. 값이 존재하지 않기 때문에 반환 값을 return 할 수 없기 때문입니다.

다음과 같은 코드를 컴파일 할 수 있습니다.

{% highlight kotlin %}
fun crash(): Nothing {
    throw Exception()
}

fun mainLoop(proc: ()-> Unit): Nothing {
    while (true) {
        proc()
    }
}
{% endhighlight %}

이외에도 Nothing의 값이 존재하지 않는 것을 이용하여 `null`에만 매칭되는 변수의 형태를 만들 수 있습니다. 예를 들면 다음과 같습니다.

{% highlight kotlin %}
class Json {
    constructor(aNull: Nothing?) {}
    constructor(aString: String) {}
}
{% endhighlight %}

이렇게 하면 `Json(null)`은 첫 번째 생성자, `Json("aaa")`는 두번째 생성자라는 식으로 오버로드를 구분할 수 있습니다. Kotlin에서는 null 자체에는 자료형이 없기 때문에 이렇게 Nothing을 사용하고 있습니다.

그런데 값이 존재하지 않는데 할당 할 수 있다는 것은 무슨 뜻인가하면, 제네릭의 Variance에서 이것이 효과가 있습니다. 아래를 예로 들어보곘습니다.

{% highlight kotlin %}
class Result<out T: Any, out E: Any> 
    private constructor(
        val value: T?, 
        val error: E?) 
{
    companion object {
        fun <T: Any, E: Any> Ok(value: T): Result<T, E> = Result(value, null)
        fun <T: Any, E: Any> Error(error: E): Result<T, E> = Result(null, error)
    }
}

fun proc1(): Result<Int, Nothing> {
    return Result.Ok(3)
}

fun main(args: Array<String>) {
    val ret: Result<Int, Exception> = proc1()
}
{% endhighlight %}

Result는 값과 에러의 두 가지 자료형를 covariance로 가지는 제너릭형입니다. 여기서 `proc1`은 절대로 문제가 생길 일이 없는 메소드이므로 오류값에 대해 Nothing으로 지정하고 있습니다.
그리고 그 결과를 `Result<Int, Exception>`에 대입하고 있습니다. 즉, 일반 오류가 있을 수 있는 경우의 처리에 대해 에러가 없었던 경우의 자료형을 형변환 없이 안전하게 할당 할 수 있습니다.

이것은 `Nothing is Exception`이기 떄문입니다만 is의 오른쪽에는 어떤 자료형도 넣을 수도 있습니다. Exception 대신 에러 메세지로 String으로 에러를 핸들링하고 있는 경우에도 `Result<Int, String>`에 `Result<Int, Nothing>`을 넣을 수 있다는 것입니다. 값이 존재하지 않기 때문에 무엇이든 될 수 있다는 것은 흥미롭습니다.

### 데이터 클래스와 튜플

Kotlin에는 데이터 클래스라는 기능이 있습니다.

{% highlight kotlin %}
data class Vector3(val x: Double, val y: Double, val z: Double)

fun main(args: Array<String>) {
    val a = Vector3(1.0, 2.0, 3.0)
    println(a) // Vector3(x=1.0, y=2.0, z=3.0) 라고 출력됩니다.
    val (x, y, z) = a
    val b = a.copy(x=0.0, z=4.0)
    println(b) // Vector3(x=0.0, y=2.0, z=4.0) 라고 출력됩니다.
}
{% endhighlight %}

데이터 클래스를 이용하면 몇개의 메소드가 자동적으로 생성됩니다.

`equals`와 `hashCode`가 정의됩니다. 이것을 통해 직접 비교를 할 수 있으며 Map의 키로서도 쓸 수 있습니다.

`toString`이 정의됩니다. 프로퍼티의 값이 표시되기 때문에 디버깅이 편합니다.

`componentN`이 정의됩니다. 위 코드에서 Vector3의 경우에는 `component1()`, `component2()`, `component3()`이 정의되겠군요. 이것은 각각의 프로퍼티에 대한 getter입니다. 그리고 이것이 정의된 클래스는 이러한 프로퍼티를 변수에 각각 할당할 수 있습니다. `val (x, y, z) = a` 이 대목에서 볼 수 있는 부분입니다.

`copy`가 정의됩니다. 이것은 프로퍼티와 동명의 인수를 취하는 메소드에서 기본 인수로서 자신의 프로퍼티 값이 설정되어 있습니다. 그리고 인수로 지정된 속성을 지정한 새로운 인스턴스를 반환합니다. 따라서 특정 프로퍼티만을 바꾼 복사본을 만드는 방법입니다.

불변 프로그래밍(Immutable Programming)을 하려고 하면 특정 프로퍼티만 바꾼 복사본을 만드는게 복잡합니다. `withName(newName) //name 만 변경한 복사본을 반환`와 같이 하나만 변경하는 것을 모든 프로퍼티에 대해 준비하더라도 다수의 프로퍼티를 변경할 때는 그만큼의 메소드 체인을 써야합니다. 한편, 모든 프로퍼티를 가지는 생성자는 있습니다만, 모두는 변화하지 않는 경우는 같은 값을 다시 지정하는 것이 귀찮습니다. `copy`는 이 귀찮은 일로부터 프로그래머를 해방시켜주어 불변의 원칙을 더욱 쉽게 사용할 수 있게 해줍니다.

Kotlin에서는 튜플 기능은 존재하지 않습니다. 그러나 데이터 클래스를 이용하면 같은 기능을 이용할 수 있습니다. 위에서 예를 나타낸 것과 같이 클래스 정의라고 해봤자 최소한의 타이핑으로 할 수 있으므로 그다지 귀찮은 일은 아닙니다.

### 별명 임포트

Kotlin에서는 별명 임포트라는 기능이 있습니다. 다른 두 개의 패키지에 동일한 클래스의 이름이 있을 때 각각 별명을 붙여 가져올 수 있는 기능으로 그 긴 풀 패키지 네임을 쓸 필요가 없습니다.

{% highlight kotlin %}
import com.omochimetaru.Bitmap as MyBitmap
import android.graphics.Bitmap as ABitmap

fun hoge(a: MyBitmap) {
}

fun fuga(a: ABitmap) {
}
{% endhighlight %}

Swift에서도 같은 기능을 쓸 수 있습니다. Java라면 이게 괴로웠겠죠?

{% highlight java %}
import com.omochimetaru.Bitmap;
import android.graphics.Bitmap;

void hoge(com.omochimetaru.Bitmap a) {
}

void fuga(android.graphics.Bitmap a) {
}
{% endhighlight %}

### Enum, 값을 포함한 Enum, Sealed Class(Tagged Enum)

Kotlin에서도 당연히 Enum이 있습니다.

{% highlight kotlin %}
enum class Direction {
    NORTH, SOUTH, WEST, EAST
}

enum class Color(val rgb: Int) {
    RED(0xFF0000),
    GREEN(0x00FF00),
    BLUE(0x0000FF)
}
{% endhighlight %}

두번째 예와 같이 값을 포함한 Enum도 만들 수 있습니다. 그러나 Swift에서 할 수 있는 같은 enum마다 다른 property를 갖게 하는 Tagged Enum이라는 기능은 enum으로는 만들 수 없습니다.

Swift의 예를 한번 보시죠.

{% highlight swift %}
enum Either<T, U> {
    case Left(T)
    case Right(U)
}
{% endhighlight %}

Left와 Right에서 프로퍼티의 자료형이 다릅니다. 기타 Optional에서는 Some에는 프로퍼티가 있지만 None에는 없는 것과 같은 패턴도 있습니다.

Kotlin에는 `sealed class`라는걸 이용해서 같은 것을 만들 수가 있습니다. sealed class라는 것은 상속을 금지한 클래스입니다. 그러나 그 클래스의 내부에서는 상속할 수 있습니다. 따라서 사전에 준비한 서브클래스만을 가질 수 있는 클래스가 됩니다.

그렇다면 when문(C나 Java의 switch문)에서 자료형 판정을 체크할 수 있어서 분기에서 문제가 생기지 않는 것을 컴파일러에 의해 보장받습니다.

{% highlight kotlin %}
sealed class Expr {
    class Const(val number: Double) : Expr()
    class Sum(e1: Expr, e2: Expr) : Expr()
    object NotANumber : Expr()
}

fun eval(expr: Expr): Double = when(expr) {
    is Const -> expr.number
    is Sum -> eval(expr.e1) + eval(expr.e2)
    NotANumber -> Double.NaN
    // the `else` clause is not required because we've covered all the cases
}
{% endhighlight %}

위의 예와 같이 Smart Cast가 있으므로 when문에서는 같은 변수 이름이 이미 형변환된 상태입니다.

### Type Alias가 없다.

Kotlin에서는 Type Alias와 같은 기능이 없습니다. Swift에서는 까다로운 클로져형 등에 이름을 붙일 수 있지만, 이런 코드를 Kotlin으로 이식하면 전부 빨간 밑줄이 그어집니다.

## 끝으로

이 내용 중 쓸 수 없는 경우도 있겠지만 여기까지 읽은 사람이라면 꽤나 Kotlin이 쓰고 싶은게 아닐까요!