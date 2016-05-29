---
layout: post
title: "[번역] RxJava를 3일만에 입문해서, 안드로이드 애플리케이션의 리스트 작업이나 비동기 처리와 알림을 해결한 이야기."
date: 2016-05-29 16:55:00 +0900
categories: Code
tags: android rxjava development observable featured
---

이번 글도 [@yuya_presto](http://twitter.com/yuya_presto)님이 쓰신 [글](http://qiita.com/yuya_presto/items/152fa80d073d865cfc90)을 한국어로 번역한 글입니다. 일부 오역이나 의역이 있을 수 있으며 이 부분에 대해서 양해를 부탁드리며 댓글로의 지적도 환영합니다, 좋은 글을 한국어로도 번역할 수 있게 해주신 yuya_presto님께 감사하다는 말씀 드립니다.

Java 8과 RxJava를 최대한 활용해서 이렇게 사용할 수 있다라는걸 보여주는 좋은 예제 글인 것 같습니다. **글을 읽으시고 나서 하단의 Recommend나 댓글, SNS로의 공유는 힘이 됩니다! 원작자에 대한 감사 댓글도 달아주신다면 일본어로 번역해서 전달해드릴 수 있도록 하겠습니다.** Rx쪽 시리즈 글들은 시간이 나는대로 허락을 받아서 번역할 수 있도록 하겠습니다.

## 왜 이런 글을 썼는가?

지금 개발 중인 프로젝트에서 RxJava를 도입했기 때문에, 실제로 사용한 예와 찾아보지 않으면 알 수 없는 것들을 올려뒀습니다.

그렇게 도입(RetroLambda를 위해 JDK8도 도입)했었을 때의 장점을 이야기해도 샘플 코드가 없으면 알 수 없다는 이야기를 들어왔기 때문에 실제로 무엇이 해결되었는지, 어떤 코드로 해결했는지와 그것을 위해 공부해야만 했던 점들에 대해서 써봤습니다.

(+1) 경고: 만들어둔 코드에서는 해결되었습니다만, 아직 릴리즈 단계는 아니기 때문에 그 점에 충분히 유의해주세요. 변경 사항이 있으면 다시 이야기하겠습니다.

(+2) 릴리즈한 뒤 안정적으로 운용하고 있습니다. 최근까지 모니터링에 어려움이 있었지만 그 부분도 수정했습니다. 이 기사에 대한 모니터링 스니펫 코드도 추가해뒀습니다.

## 왜 RxJava를 도입했는가?

다음 문제들을 모두 해결해줄 수 있는게 RxJava라고 생각했고 리팩토링도 할 겸 같이 도입하게 되었습니다. (기세로 밀어붙여 죄송합니다…)

 - 팀 내에서 안드로이드의 비동기 처리나 그 외 에러 핸들링을 처리하는게 귀찮다는 이야기가 계속 전부터 나오고 있었습니다.
 - 리스트 작업이나 람다식을 쓰는게 소스 코드의 가독성이 높은 것 같았습니다.
 - 리팩토링을 통해 데이터 소스가 변경되었을 때, 화면의 갱신을 이벤트로 처리하도록 방침을 바꿨습니다.
 - Cookpad에서는 처음부터 리스트 작업부터 도입했다는 것 같습니다. ([Android 개발에서 RxJava를 팀에 도입한 이야기](http://techlife.cookpad.com/entry/2015/04/17/100000))

그러나 당초 리스트 조작이나 Loader 완료 후의 상태 변경의 전달에만 사용하기로 했습니다만, [@ainame](http://qiita.com/ainame)님이 "이런 코드라면 장점이 잘 와닿지 않는다."라는 말을 듣고 Loader와 EventBus로 구현된 부분들을 전부 RxJava로 바꾸게 되었습니다.

## RxJava의 기본

Reactive Programming의 개념에 대해서는 참고용 글을 쓰는데 그쳤고, 이번 글에서는 실제 사용 예에 대해서 다뤄보도록 하겠습니다.

- 개념이나 익숙해지는 방법에 대해서라면 이 슬라이드를 보는게 알기 쉽습니다. ([RxJava 학습의 베스트 프랙티스같은 것들](https://speakerdeck.com/sys1yagi/rxjavaxue-xi-falsehesutohurakuteisutuhoimofalse))
- [(번역) 당신이 원하고 있던 리액티브 프로그래밍 입문](http://ninjinkun.hatenablog.com/entry/introrxja)
- [ReactiveX의 Intro 페이지](http://reactivex.io/intro.html)

※ 여담입니다만, 본인은 하스켈이나 논문을 읽어본 적이 없기 때문에 Functional Reactive Programming이라는 개념에 대해서는 잘 알지 못합니다. 이 점 양해해주세요.

공통적인 사용법만 아래에 적어뒀습니다. 코드 샘플은 후술하도록 하겠습니다.

![]({{ site.url }}/assets/images/20160529/1.png)

 - [Observable](http://reactivex.io/documentation/observable.html)부터 Item이 동기식으로나 비동기식으로 내려옵니다. (스트림)
 - `Observable.from(List)`를 사용하면, List 안에 있는 객체가 하나씩 스트림으로 내려오는 Observable를 만드는 것이 가능합니다.
 - `map()`이나 `filter()`를 시작으로 하는 [Operator](http://reactivex.io/documentation/operators.html)를 사용하면 스트림으로 내려오는 Item을 수정할 수 있습니다.
 - 동기적으로 결과를 얻고 싶을 때에는 `toBlocking()`을 사용합니다.
 - `observeOn()`에 [Scheduler](http://reactivex.io/documentation/scheduler.html)를 설정해두면 `subscribe()`의 콜백을 설정해둔 스레드(메인스레드 등…)에서 호출하는 것이 가능합니다.
 - 취소하고 싶을 때에는 `unsubscribe()`를 실행합니다. (다만, 적절히 구현된 Observable에만 Activity나 Fragment가 메모리 누수를 일으키지 않습니다.)

메인 문서는 RxJava의 Repository에서 제공하는 Wiki를 보는 것이 좋을 것 같습니다. 작동의 확인은 [http://rxmarbles.com](http://rxmarbles.com)이 아마 제일 편리할겁니다. 다만 RxJS로 작성되어있기 때문에, 이름이 다른 메소드 등이 존재할 수 있습니다.

## 현재의 과제와 RxJava로의 해결책

(군데군데 `arg -> process()`라던가 `Class::method`같은 표현이 나옵니다만, 이것은 Java 8에서 쓰이는 람다 표현식이기 때문에 RetroLambda를 설정하지 않은 분들은 적절한 Callback을 선언해주세요.)

### 리스트 처리가 아직도 for문으로 처리된다?

**(+1) RxJava는 단순히 루프로 돌아가고 있는게 아니기 때문에, `zip()` 등의 일부 메소드의 처리 속도가 느린 것 같습니다. 리스트 작업을 편리하게 하기 위해서는 Java 8의 Stream API의 백포팅 라이브러리인 [Lightweight-Stream-API](https://github.com/aNNiMON/Lightweight-Stream-API)를 추천합니다. 메소드 수는 350여가지입니다.**

Java 8부터 Lambda 식이나 Stream API를 사용해서 `map()`이나 `filter()`와 같은 Ruby, Python, Underscore.js / ECMAScript5와 비슷한 for loop를 사용하지 않은 리스트 처리가 가능해졌습니다.

```java
// Java 7
List<String> otherUserNames = new ArrayList<>(users.size);
for (User user : users) {
    if (user.id != selfUser.id) {
        otherUserNames.add(user.getName());
    }
}
```

```java
// Java 8
List<String> otherUserNames = users.stream()
    .filter(user -> user.id != selfUser.id)
    .map(User::getName) // user -> user.getName()의 단순 표현, method references라고 부릅니다.
    .collect(Collectors.toList());
```

new나 add 같은 절차적인 코드가 사라지고 리스트에 대한 가공만 코드에 나타나서 읽기가 쉽다! 하지만 Android에서 Java 8을 쓸 수 있는건 꽤 먼 이야기가 될 것 같습니다. *(역주 : Android N Preview부터는 Jack Toolchain을 이용하여 Java 8의 기능들을 사용할 수 있습니다.)*

#### 그거 RxJava로 되는데요…

```java
// RxJava
List<String> otherUserNames = Observable.from(users)
    .filter(user -> user.id != selfUser.id)
    .map(User::getName)
    .toList().toBlocking().single(); // 전부 리스트로 묶어서, 동기 처리할 수 있도록 설정하고, 하나로 결과를 합칩니다.
```

비동기 처리를 전제로 하고 있기 때문에, 동기 처리로 바꾸기 위해서는 `toBlocking()`을 계속 호출하는게 버릇처럼 되곘지만 그 부분만 해결한다면 충분히 실용적일 것이라고 생각합니다.

サンプルはこの記事にいくつか載っています：Java 8: No more loopsをRxJavaでやる(Androidの環境で)

샘플 코드는 이 글에 몇가지 들어있습니다. ([Java 8: No More loops를 안드로이드 환경에서 RxJava로 해보자.](http://sys1yagi.hatenablog.com/entry/2015/01/14/141710))

### 비동기 (백그라운드) 처리가 귀찮은 문제

안드로이드의 프레임워크에서 백그라운드 처리를 실행하기 위해 사용하는 패턴은 주로 아래에 있는 세가지입니다. 하지만, 각자의 단점이 있습니다.

 - [AsyncTask](http://developer.android.com/reference/android/os/AsyncTask.html)
	 - 실행 중에 Activity, Fragment가 Destroy되면, 특별히 노력하지 않는 한 메모리 누수가 일어나거나 크래쉬가 일어난다.
	 - 특별히 cancel할 때의 처리가 어렵다.
	 - 에러를 핸들링하는 부분이 귀찮다.
 - [AsyncTaskLoader](http://developer.android.com/reference/android/content/AsyncTaskLoader.html)
	 - 올바르게 구현하기 위한 Boilerplate가 매우 어렵다. (전에 코드를 읽을 때는 링크 출처의 공식 샘플도 잘못 구현한 것 같았다.)
	 - destroy나 화면 회전이 일어날 떄, Activity나 Fragment가 비활성화될 때 등 조건에 따라 동작이 복잡해진다.
	 - Activity나 Fragment에서밖에 쓸 수 없다.
	 - 파라미터로 Bundle밖에 줄 수 없다. (그 의도는 알겠지만 마음에 들지는 않는다.)
	 - 에러를 핸들링하는 부분이 귀찮다.
 - [IntentService](http://techbooster.jpn.org/andriod/application/1570/)
	 - 결과를 반환하는 방법이 이벤트(EventBus나 LocalBroadcast)로 한정된다.
	 - 만들 때마다 AndroidManifest에서의 추가가 필요하다.

#### 그거, RxJava로 되는데요…

해결책으로 Promise를 도입하는 방법이 있습니다. RxJava의 Observable는 Promise처럼 사용할 수 있습니다.

```java
observable
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe(result -> render(result));
```

예를 들면 REST Client 라이브러리인 Retrofit은 RxJava에 대응하고 있어서, Observable를 반환하는 것이 가능합니다.

```java
public interface Client {
    @GET("/users")
    List<User> getUsers();

    @GET("/users")
    Observable<List<User>> users(); // Retrofit의 경우 처음부터 백그라운드 스레드에서 처리됩니다.
}
```

이것을 이용한 실제 구현 예는 다음과 같습니다.

```java
public class UserListFragment extends Fragment {
    private Subscription mSubscription;
    private Client mClient;
    ...

    public void onStart() {
        super.onStart();
        mSubscription = mClient.users()
            .observeOn(AndroidSchedulers.mainThread()) // 결과의 통지는 UI Thread에서 실행됩니다.
            .subscribe(                                // subscribe의 타이밍에 처리가 시작되어 Callback에 결과가 보내집니다.
                this::render,                          // 결과를 render 메소드에 전달합니다.
                error -> showErrorAlert(error),        // 에러가 발생할 때의 예외 처리를 지정해줍니다.（optional）
                () -> showCompletedAlert());           // 정상적으로 처리가 끝났을 때의 처리를 지정해줍니다. (optional)
    }
    // ※ mainThread()는 RxAndroid의 구현을 참조할 것.

    public void onStop() {
        // View가 사라지기 전에 처리가 끝나지 않았어도 unsubscript를 통해 취소하고, callback으로 넘어가지 않도록 합니다.
        // (Observable이 바르게 구현되어 있다면) 참조가 사라지면 Activity나 Fragment가 메모리 누수를 일으키지 않습니다.
        // 어느 라이프사이클에서 subscribe나 unsubscribe할지 베스트 케이스가 정해지지 않았습니다. (역주: 있으면 공유를 부탁드립니다...)
        mSubscription.unsubscribe();
        super.onStop();
    }

    private void render(List<User> userList) {
        ...
    }

    ...
}
```

이처럼 AsyncTask나 AsyncTaskLoader, IntentService를 새로 만들지 않고도 메모리 누수 없이 심플하게 코드를 작성할 수 있습니다…! 이번에는 화면 회전을 할 때 특별히 캐시를 지정하지는 않도록 결론 지은 구현입니다만, 가능하면 그 근처에서도 try해보려고 합니다.

※ Promise와 Observable의 큰 차이점은 여러 값을 반환할 수 있는가입니다.

한편, 이번에 직접 만든 `AndroidSchedulers.mainThread()`는 RxAndroid에서 만든 것을 이용하지 않고 제가 다시 구현한 것을 사용하고 있습니다. RxAndroid을 사용하지 않은 이유는 후술합니다.

### 변경 알림 흐름을 쫓기 어려워진 문제

표시할 때마다 Fragment에서 Model을 호출하는 장소에서 변경 알림 이벤트에 의한 View의 갱신을 가하면 호출의 흐름이 복잡하게 되어버립니다. 또 이것을 EventBus를 통해서 구현하면 그 이벤트가 어디서 날아오는지 명확히 알 수 없다는 문제도 존재합니다.

```
                                    ┌────────┐
                                    | Model2 | ──( save )───┐
                                    └────────┘              ↓
┌──────┐            ┌───────────────────┐ ──( call )─→ ┌───────┐ ──( call )─→ ┌────────┐
| View |←─(render)──| Activity/Fragment |              | Model |              | DB/API |
└──────┘            └───────────────────┘ ←─(return)── └───────┘ ←─(return)── └────────┘
                        ↑           ┌───────────┐           │
                        └─(event)── | Event Bus | ←─(post)──┘
                                    └───────────┘
```

이것을 Observer 패턴을 이용하면 변경 내용이 통지될 때마다 render하는 것만으로도 괜찮아지며, 또 subscribe할 때에 Model를 참조하기 때문에 가독성이 높아집니다.

```

                                   ┌────────┐
                                   | Model2 | ──( save )───┐
                                   └────────┘              ↓
┌──────┐            ┌───────────────────┐              ┌───────┐ ──( call )─→ ┌────────┐
| View |←─(render)──| Activity/Fragment | ←─(update)── | Model |              | DB/API |
└──────┘            └───────────────────┘              └───────┘ ←─(return)── └────────┘
                            │                              ↑
                            └ ─ ─ ─ (subscribe once) ─ ─ ─ ┘
```

#### 그거 RxJava로… (이하 생략)

**(+1) 원래의 구현은 타이밍에 따라 최신 상태를 받을 수 없게 되어버리는 문제와 `onBackpressureLatest()`가 제대로 동작하지 않았었기 때문에 `replay(1)`를 사용하여 다시 작성되었습니다.**

```java
public class UserModel {
    ...

    // 통지가 올 때마다 Request를 날리기 위한 Observable을 만듭니다.
    private PublishSubject<Void> mUpdateNotificationPublisher = PublishSubject.create()
    private Observable<List<User>> mUserUpdateObservable = mUpdateNotificationPublisher
            .onBackpressureLatest()            // 뒤에서 처리할 수 있는 것보다 많이 오게 된다면 최근에 하나만 큐잉하고 나머지를 버립니다.
            .flatMap(aVoid -> mClient.users(), 1)            // 값이 날아 오면 Request를 던지는 Observable을 돌려 준다. flatMap은 반환된 Observable를 subscribe()한 뒤에 연결합니다. maxConcurrent를 1로 설정하게 되면 동시에 1개의 리퀘스트만 설정할 수 있게 됩니다.
            .replay(1).refCount()             // 여러번 subscribe되어도 1개의 결과를 전체에 배포합니다. replay(1)는 subscribe()되었을 때 최신인 하나의 onNext()를 통과합니다. refCount()는 누군가 한명이라도 subscribe()하고 있을 때 상류의 처리를 담당합니다.
            // ※ publish()혹은 replay() 없이는 subscribe()한 횟수만큼 (낭비) 병렬로 Request를 날려 버립니다. 여러 번 달리는 이유는 Hot / Cold Observable의 개념에서 설명하겠습니다.

    private void notifyUpdate() {
        mUpdateNotificationPublisher.onNext(null);
    }

    public Observable<List<User>> observeUsers() {
				// 몇번 호출되더라도 같은 Hot Observable를 subscribe() 합니다.
        return mUserUpdateObservable;
    }
}
```

```java
public class UserListFragment extends Fragment {
    private Subscription mSubscription;
    private UserModel mUserModel;
    ...

    public void onStart() {
        super.onStart();
        mSubscription = mUserModel.observeUsers()
            .observeOn(AndroidSchedulers.mainThread()) // 결과의 통지는 UI Thread에서 실행됩니다.
            .subscribe(this::render)                   // subscribe로 감시와 초기의 Request가 시작되며, 변경이 있을 때마다 render 메소드가 호출되게 됩니다.
    }

    public void onStop() {
        mSubscription.unsubscribe();
        super.onStop();
    }

    private void render(List<User> userList) {
        ...
    }

    ...
}
```

Fragment쪽에 특별히 복잡한 처리 코드를 적지 않고서도 Reactive한 느낌이 넘치는, 변경이 마음대로 반영되는 구현이 완성되었습니다…!

※ 여담입니다만, 누구라도 post할 수 있는 이벤트라면 EventBus를 쓰는 것이 낫고 특정한 상대에게 이벤트를 보여주고 싶을 때에는 Observable를 쓰는 제안을 받은 적이 있습니다.

## 도입하고 싶어졌다면?

 - [RxJava](https://github.com/ReactiveX/RxJava/releases): 본체
	 - `build.gradle`에 `compile 'io.reactivex:rxjava:x.xx.xx'` 최신 버전은 위의 링크에서 확인해주세요.
 - [retrolambda](https://github.com/evant/gradle-retrolambda): Lambda식
	 - 안드로이드에서도 람다식을 쓸 수 있게 됩니다.
 - [RxJavaDebug](https://github.com/ReactiveX/RxJavaDebug): 디버그용
	 - 결국 사용하지 않게 됩니다.

## 나름대로 알아보지 않으면 잘 몰랐던 것들

우선은 구현 예를 적어봤습니다만, 리스트 작업 이외에는 이해해야할 것들이 점점 많아집니다.

 - 리스트 작업 : 스트림 처리, Operator, `toBlocking()`
 - 비동기 처리 : 리스트 처리 + `subscribe()` + `unsubscribe()`, Scheduler, (필요에 따라서) Observable의 자작 방법
 - 변경 통지 : 비동기 처리 + Subject + 가능하면 Backpressure

이 이후는 솔직히 처음부터 이해하려고 하면 힘든 영역이라고 생각되기 때문에, 간단한 리스트 처리부터 시작하는 편이 좋다고 생각합니다. 비동기 처리를 해보겠어…! 라고 생각한다면 다음 순서대로 해보세요.

### `unsubscribe()`하는 것이 귀찮다. ~~한편 그것을 어떻게 하는 RxAndroid는 지금 사용할 수 없다~~.

(+1) [RxLifecycle](https://github.com/trello/RxLifecycle)가 원래의 RxAndroid의 unsubscribe에 가깝습니다만, 위에서 쓴 것처럼 onStart()만으로도 충분했다고 생각하기 때문에 쓰고 있지 않습니다.

**(+2) subscribe/unsbuscribe 라이프 사이클에 관련해서는 별도의 Qiita 글 ([RxJava의 자세한 설명](http://qiita.com/yuya_presto/items/c8c3d77ac958c9c8f67b))에 지금의 견해를 적었습니다.**

`subscribe()`에서 반환되는 Subscription을 `unsubscribe()` 하지 않으면 AsyncTask처럼 작업이 완료될 떄까지 Activity나 Fragment가 메모리에서 누수되어 버립니다.(일단 `onComplete()` 또는 `onError()`시 자동으로 `unsubscribe()` 됩니다.) 원래는 RxAndroid에서 대응할 수 있을 것이라고 생각했습니다만, 너무 커지기 때문에 불편해질 것이라는 [Jake Wharton의 의견](https://github.com/ReactiveX/RxAndroid/issues/172)대로 지금은 그다지 사용되고 있지 않는 것 같습니다.

학습 코스트를 줄이기 위해도 겸해 `onCreate()` 등의 메소드에 `subscribe()`와 `unsubscribe()`를 직접 추가하기로 했습니다. Subscription 관리를 간단하게 하기 위해서는 `CompositeSubscription`에 `add()`한 뒤, 나중에 모아서 한꺼번에 `unsubscribe()`합니다.

```java
public class UserListFragment extends Fragment {
    private CompositeSubscription mCompositeSubscription;
    private Client mClient;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mCompositeSubscription = new CompositeSubscription();
        Subscription subscription = mClient.users()
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(result -> render(result));
        mCompositeSubscription.add(subscription);
    }

    public void onDestroy() {
        mCompositeSubscription.unsubscribe();
        super.onDestroy();
    }

    ...
}
```

업데이트 작업을 수행하는 경우 등 `subscribe()`를 여러 번 호출하는 경우가 있다고 생각 합니다만, 이 경우 작업이 완료될 때마다 매번 CompositeSubscription에서 `remove()`하지 않으면 점점 늘어나버립니다. 따라서 `subscribe()`와 `unsubscribe()` (혹은 종료)시에 마음대로 `CompositeObservable`의 `add()`와 `remove()`를 호출할 수 있는 구조를 만들었습니다. ([Gist](https://gist.github.com/ypresto/accec4409654a1830f54))

**(+1) 이것은 반드시 `subscribe()`의 맨 마지막에 호출하지 않으면 잘 unsubscribe되지 않는 경우가 있으므로 주의가 필요합니다.**

```java
mClient.users()
    .observeOn(AndroidSchedulers.mainThread())
    .lift(CompositeObservables.attachTo(mCompositeObservable)) // lift는 커스텀 Operator를 사용하기 위해서 쓰는 것입니다.
    .subscribe(result -> render(result));
```

※ CompositeSubscription는 한 번 unsubscribe하면 다시 사용할 수 없기 때문에 주의하세요. `attachTo()`는 `mCompositeObservable`을 만들고 때마다 다시 호출해야합니다. [http://gfx.hatenablog.com/entry/2015/06/08/091656](http://gfx.hatenablog.com/entry/2015/06/08/091656)

### `subscribeOn()`, `observeOn()`과 Scheduler 스레드 전환과 범위

**(+1) 이 글을 썼을 때보다 Rx에 대한 이해가 깊어졌기 때문에 의사코드와 설명을 다른 Qiita 글([RxJava의 자세한 설명](http://qiita.com/yuya_presto/items/c8c3d77ac958c9c8f67b))에 썼습니다.**

먼저 이해하는데 시간이 꽤 걸린 부분 중 하나입니다만, 실행 스레드를 전환하기 위해서 Scheduler를 사용합니다. Scheduler를 사용하면 스트림의 실행(`onNext()`, `onComplete()`, `onError()` 등의 호출) 스레드를 변경할 수 있습니다.

 - `subscribeOn()`: `subscribe()`에서 실행되는 모든 스레드
 - `observeOn()`: 호출한 이후의 스트림을 다른 스레드에서 실행

`subscribeOn()`은 느린 메소드를를 `map()`과 사용자가 정의한 Observable에서 호출할 때 지정해야합니다. [그러나 가장 소스에 가까운 `subscribeOn()`만 유효](https://groups.google.com/d/msg/rxjava/XXJJPhn8PHQ/BJhBUNHnwtgJ)합니다. 여러번 호출하면 스레드가 생성되는만큼 낭비라는 것. 또한 Retrofit같은 경우 [처음부터 실행되는 스레드가 정해져 있는](https://github.com/square/retrofit/issues/830#issuecomment-98441589) 것 같아서 효과가 없는 것 같습니다. `observeOn()`은 View의 업데이트는 메인 스레드에서만 호출할 수 있기 때문에 비동기 요청을 했을 경우에는 `subscribe()` 직전에 반드시 호출해야 합니다. RxAndroid의 1.0은 AndroidSchedulers의 구현만을 포함하는 라이브러리도 존재하기 때문에 이를 사용하는 것이 좋습니다.

또한 문서화되지 않는 한 `subscribeOn()`의 지정이 없으면 `subscribe()` 스레드에서 실행됩니다.

※ Observable을 반환할 수 있는 `flatMap()`을 사용한 경우가 까다롭긴 하지만, 반환된 Observable에서 `subscribeOn()`을 호출하고 있는 경우 `onNext()`를 호출한 Observable에 대응하는 스레드에서 계속 처리되는 것 같습니다. [https://groups.google.com/d/msg/rxjava/hVFl4YCORDQ/F-KorYBmpV0J](https://groups.google.com/d/msg/rxjava/hVFl4YCORDQ/F-KorYBmpV0J)

### 동기적 메소드를 Observable로 만드는 방법

**(+1) 아래의 구현를 이용하면 특히 느린 처리에서 subscriber가 누출하여 결과 Activity 등이 같이 메모리에서 누출되어 버립니다. 자세한 내용은 다른 Qiita 글로 쓸 예정입니다.**

가장 간단한 방법을 하면 다음과 같이 됩니다.

```java
Observable.create(new Observable.OnSubscribe<List<User>>() {
    @Override
    public void call(Subscriber<? super List<User>> subscriber) {
        subscriber.onNext(mClient.getUsers());
        subscriber.onCompleted();
    }
});
```

입니다만, 사실은 처리가 끝날 떄까지 subscriber(Activity나 Fragment 속의 Inner Class나 Lambda식 혹은 그것을 랩핑한 객체)에 대한 참조가 유지되기 때문에 AsyncTask와 마찬가지로 메모리 누수가 발생합니다. AbstractOnSubscribe를 사용하면 처음부터 `unsubscribe()`에 의한 취소 등을 지원하는게 가능해집니다.

```java
// 주의: AbstractOnSubscribe는 아직 Experimental 단계입니다.
Observable.create(AbstractOnSubscribe.create(new Action1<AbstractOnSubscribe.SubscriptionState<List<User>, Void>>() {
    @Override
    public void call(AbstractOnSubscribe.SubscriptionState<List<MediaFile>, Void> subscriptionState) {
        subscriptionState.onNext(client.getUsers());
        subscriptionState.onCompleted();
    }
})).subscribeOn(Schedulers.io()); 
```

※ [rxjava-async-util](https://github.com/ReactiveX/RxJava/wiki/를 사용하면 `AsyncObservable.start()`를 사용하는 것도 가능합니다만, 값이 캐싱되거나 하는 일이 있기 때문에 이번엔 사용하지 않았습니다.

### Hot / Cold Observable 개념과 Connectable Observable이 어려운 문제

또 한가지 어려웠던 것 중 하나가 Hot과 Cold라는 개념이 있었던 것입니다.

```java
private Observable mObservable = mClient.users().map(users -> heavyMethod(users));

...

mObservable.subscribe(users -> render(users));
mObservable.subscribe(users -> render(users));
mObservable.subscribe(users -> render(users));
```

처음에는 `heavyMethod()`의 호출은 한번으로 끝난다고 생각해버렸습니다. 그러나 Observable은 비동기적이며 mObsercable에는 어떠한 결과도 캐싱되지 않고 `heavyMethod()`는 3회 호출되게 됩니다. 변경 알림을 구현하는 예에서 `share()`(`publish().refCount()`와 같음)의 호출을 하고 있었던 것은 분기의 뿌리에 처리 결과를 공유하기 때문입니다. 이처럼 분기의 뿌리가 되는 특별한 것을 Hot Observable이라고 하고, 그 이외의 일반적인 것들을 Cold Observable이라고 부릅니다. 이 부분은 ["Rx의 Hot과 Cold에 대해"](http://qiita.com/toRisouP/items/f6088963037bfda658d3)라는 글에서 자세히 설명하고 있습니다.

Connectable Observable은 subscribe되면 즉시 작동이 시작해서 Hot Observable을 모두에게 `subscribe()`가 끝날 때까지 지연시키는 구조로, `refCount()`를 사용하면 누군가가 `subscribe()`하고 있을 때만 시작되는게 됩니다. 다음과 같은 경우가 있습니다.

- `publish()`: `subscribe()`하기에 앞서 이후에 도착한 것들을 내려보낸다. (Multicast）
- `replay()`: `subscribe()`할 때마다 지금까지 도착한 item들을 전부 다시 전달합니다. (최근의 n건만 전달하는 것도 가능.)

또한 Hot Observable이 시작되면 **그 직전까지의 스트림을 대표하여 `subscribe()` 하고있는 상태**가 됩니다.

### Observable에 직접 값을 내리는 Subject를 사용하기

`Observable.from(List)`를 쓰면 먼저 결정한 값 밖에 스트림에 내릴 수 있습니다. 나중에 값을 바꿔서 내리고 싶다면 Subject를 사용해 `onNext()`을 부릅니다. Subject는 Observable이자 Callback(Subscriber)이기도 합니다.

 - PublishSubject
	 - PublishSubject의 `onNext()`를 호출할 때 `subscribe()` 콜백에 동일한 값을 전달합니다.
	 - 통지(이벤트)의 구현에 편리합니다.
 - BehaviorSubject
	 - `subscribe()`시 마지막에 `onNext()`된 값을 내리며, 이후 `onNext()`될 때마다 값을 내립니다.
	 - 변경이 일어날 때 값을 표현하는 데 유용합니다.

### Backpressure 개념

(+1) Backpressure의 구조에 대해서는 [다른 글](http://qiita.com/yuya_presto/items/0e95271bc85efe7f768e)를 썼습니다. 이쪽도 함께 부탁드립니다.

Backpressure에 대해서는 아직 공부 중입니다. ReactiveX의 intro에 나와 있는 바와 같이 Iterable는 pull(`next()`에서 따온), Observable은 push(`onNext()`에서 건너오는)입니다. push의 경우 자신이 pull하는 경우에 비해 연속 처리가 늦어질 때의 제어가 어려워집니다. 이를 제어하기 위해 얼마만큼의 `onNext()`가 연속으로 호출되어도 괜찮은지 소스 쪽에 전달하는 구조입니다.

[https://github.com/ReactiveX/RxJava/wiki/Backpressure](https://github.com/ReactiveX/RxJava/wiki/Backpressure)

UI로 문자의 입력에 따라 처리를 호출하는 경우 등에 도움이 될 것입니다만, 그런 경우에는 일정 시간 내에 이벤트 수를 제어하는 Operator를 사용해보라고 적혀 있습니다.