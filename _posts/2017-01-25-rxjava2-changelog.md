---
layout: post
title: RxJava 2.x, 무엇이 달라졌을까?
date: 2017-01-25 12:00:00 +09:00
categories: Code
tags: featured development java rxjava reactive-streams rxjava2 
---

## 글에 앞서,

RxJava 2.x은 [Reactive-Streams 표준](https://github.com/reactive-streams/reactive-streams-jvm)에 맞게 많은 부분이 바뀌었습니다. 오늘은 RxJava Wiki에 있는 [What's Different in 2.0](https://github.com/ReactiveX/RxJava/wiki/What's-different-in-2.0) 문서를 번역하면서 어떤 점들이 바뀌었나 알아보는 시간을 갖도록 하겠습니다.

------

RxJava 2.0은 Reactive-Streams의 표준 사양에 따라 처음부터 다시 작성되었습니다. 사양에 대해서는 RxJava 1.x에서 발전했으며, 리액티브 시스템과 라이브러리에 대한 공통된 기준을 제시합니다. 

왜냐하면 Reactive-Streams는 기존의 RxJava와는 아키텍처가 다르므로, 기존 RxJava의 많은 타입을 변경해야만 했습니다. 이 페이지에서는 변경된 내용을 요약하고, RxJava 1.x로 된 코드를 RxJava 2.x 코드로 다시 작성하는 법을 설명합니다.

RxJava 2.x를 위한 오퍼레이터를 작성하는 방법은 [오퍼레이터를 작성하는 법](https://github.com/ReactiveX/RxJava/wiki/Writing-operators-for-2.0)이라는 Wiki 페이지를 방문해주세요.

## 메이븐 주소와 베이스 패키지

RxJava 1.x와 RxJava 2.x를 나란히 둘 수 있도록 RxJava 2.x는 Maven 좌표 `io.reactivex.rxjava2:rxjava:2.x.y`로 받아올 수 있으며 클래스는 `io.reactivex`에서 접근할 수 있습니다.

1.x에서 2.x로 전환하는 사용자들은 import를 처음부터 다시 구성해야하므로, 조심해야 합니다. 

## Javadoc

RxJava 2.x를 위한 공식 Javadoc은 [여기](http://reactivex.io/RxJava/2.x/javadoc/)에서 보실 수 있습니다. 

## Null 값

RxJava 2.x는 더는 `null` 값을 허용하지 않으며, 다음과 같은 코드들은 즉시, 또는 다운스트림으로 NullPointerException을 발생할 것입니다.

{% highlight java %}
Observable.just(null);

Single.just(null);

Observable.fromCallable(() -> null)
    .subscribe(System.out::println, Throwable::printStackTrace);

Observable.just(1).map(v -> null)
    .subscribe(System.out::println, Throwable::printStackTrace);
{% endhighlight %}

이 말은 즉, `Observable<Void>`는 더는 값을 발생시킬 수 없으며 정상적으로 종료되거나 Exception을 발생시킵니다. API 디자이너들은 대신 `Object`가 어떤 값이 될지 보장할 수 없을 때 `Observable<Object>`를 사용할 수 있습니다. (어쨌든 관련이 없어야 합니다.) 예를 들어 신호기와 같은 소스가 필요할 때, 공유 enum을 정의하고 해당 인스턴스를 `onNext`에 담아 보낼 수 있습니다.

{% highlight java %}
enum Irrelevant { INSTANCE; }

Observable<Object> source = Observable.create((ObservableEmitter<Object> emitter) -> {
   System.out.println("Side-effect 1");
   emitter.onNext(Irrelevant.INSTANCE);

   System.out.println("Side-effect 2");
   emitter.onNext(Irrelevant.INSTANCE);

   System.out.println("Side-effect 3");
   emitter.onNext(Irrelevant.INSTANCE);
});

source.subscribe(e -> { /* Ignored. */ }, Throwable::printStackTrace);
{% endhighlight %}

## Observable과 Flowable

RxJava 0.x에서 배압 개념을 도입하면서 별도의 베이스가 되는 리액티브 클래스를 두지 않고, `Observable`을 필요에 맞게 개조해서 사용했던거에 대한 약간의 후회가 있습니다. Backpressure의 주된 문제점은 UI 이벤트와 같은 많은 핫 소스들이 합리적으로 배압되지 않고, 예기치 않은 `MissingBackpressureException`이 발생할 수 있는 것이었습니다. (즉, 초보자들은 이런 문제를 예상하지 못합니다.)

우리는 2.x에서 이러한 문제를 해결하기 위해  `io.reactivex.Observable`에는 Backpressure를 없애고, Backpressure가 적용된 새로운 기본 리액티브 클래스인 `io.reactivex.Flowable`를 만들었습니다.

좋은 소식은 오퍼레이터의 이름이 대부분 같다는 것입니다. 나쁜 소식은 import를 관리할 때 의도치 않게 Backpressure가 적용되지 않은 `io.reactivex.Observable`을 선택할 수 있으므로 조심해야 합니다.

### 어떤 타입을 써야할까?

RxJava의 최종 소비자로서 데이터 플로우를 설계하거나, 2.x에 호환되는 라이브러리를 사용할 때 `MissingBackpressureException` 또는 `OutOfMemoryError`와 같은 문제를 피하는데 도움이 되는 몇 가지 요소를 고려할 수 있습니다.

#### Observable을 써야할 때,

- 만약 플로우에 1000개 이하의 항목이 있다면, 시간이 지나면서 항목이 대부분 없어지기 때문에 애플리케이션에서 `OutOfMemoryError`가 발생할 일이 없습니다.
- 마우스 움직임이나 터치 이벤트와 같은 GUI 이벤트를 처리할 때는 합리적으로 Backpressure를 줄 수 없으며, 빈번하지도 않습니다. `Observable`을 사용하면 초당 1000개 혹은 그 이하의 항목을 처리할 수 있지만 샘플링이나 디바운싱을 사용하는 것이 좋습니다. 
- 플로우가 본질적으로는 동기식이지만 플랫폼이 Java 스트림을 지원하지 않거나 그런 기능이 있다는걸 놓쳤을 때, `Observable`을 쓰는 것이 `Flowable`을 쓰는 것보다 대부분 오버헤드가 적습니다. *(Java 6+를 지원하는 Iterable 플로우에 최적화된 IxJava도 고려할 수 있습니다.)*

#### Flowable을 써야할 때,

- 어딘가에서 생성되는 10000개 이상의 요소를 처리할 때, 체인은 소스가 생성되는 양을 제한할 수 있습니다.
- 파일을 디스크에서 읽거나 파싱하는 일은 본질적으로 블로킹이고, 풀에 기반(Pull-based)합니다. 이럴 때는 Backpressure를 통해 사용자가 제어할 수 있습니다.
- JDBC를 통해 데이터베이스를 읽는 것 또한 블로킹이고 풀에 기반을 두며, 각 다운스트림 요청에 대해 `ResultSet.next()`를 호출해서 사용자가 제어할 수 있습니다.
- 네트워크를 거치거나, 논리적 리소스를 요청하는 프로토콜을 사용하는 네트워크 (스트리밍) 입출력
- 추후에 논블로킹 리액티브 API 혹은 드라이버를 지원하게 될 수 있는, 블로킹이거나 풀에 기반을 둔 데이터 소스

## Single

하나의 `onSuccess`나 `onError`를 방출할 수 있는 기본 리액티브 타입인 `Single`은 2.x에서 처음부터 다시 디자인되었습니다. 이 아키텍처는 Reactive-Streams의 디자인에서 파생되었습니다. 해당 소비자 타입인 `rx.Single.SingleSubscriber`는 `rx.Subscription`을 받을 수 있도록 인터페이스 `io.reactivex.SingleObserver<T>`는 딱 3개의 메소드만을 가지도록 다음과 같이 바뀌었습니다. 

{% highlight java %}
interface SingleObserver<T> {
    void onSubscribe(Disposable d);
    void onSuccess(T value);
    void onError(Throwable error);
}
{% endhighlight %}

이를 통해 `onSubscribe(onSuccess | onError)?` 규격을 따를 수 있게끔 되었습니다.

## Completable

`Completable` 타입은 대체로 비슷합니다. 1.x 때 Reactive-Streams의 스타일에 따라 설계되었기 때문에 사용자 레벨의 변경사항은 없습니다.

명칭이 바뀐 것과 비슷하게, `rx.Completable.CompletableSubscriber`는 `onSubscribe(Disposable)`와 함께 `io.reactivex.CompleteObserver`가 되었습니다.

{% highlight java %}
interface CompletableObserver<T> {
    void onSubscribe(Disposable d);
    void onComplete();
    void onError(Throwable error);
}
{% endhighlight %}

이를 통해 `onSubscribe(onSuccess | onError)?` 규격을 계속 따르고 있습니다.

## Maybe

RxJava 2.0.0-RC2에선 새로운 기본 리액티브 타입인 `Maybe`가 도입되었습니다. 개념적으로 `Single`과 `Completable`의 리액티브 소스에 의해 0개 혹은 1개의 항목, 혹은 에러를 발생할 수 있는 패턴을 포착할 수 있도록 제공합니다.

`Maybe` 클래스는 `MaybeSource`를 기본 인터페이스 타입으로, `onSubscribe (onSuccess | onError | onComplete)?` 규격을 따르는 `MaybeObserver`를 데이터를 수신하는 인터페이스로 이용합니다. 왜냐면 많아도 1개의 항목이 발생할 수 있기 때문에, `Maybe` 타입에는 Backpressure 개념이 없습니다. (왜냐하면 알 수 없는 길이의 `Flowable`이나 `Observable`과 같이 Buffer가 팽창할 가능성이 없기 때문입니다.)

이는 `onSubscribe(Disposable)`의 호출에는 잠재적으로 다른 `onXXX` 메소드 중 하나가 따라옵니다. `Flowable`과는 달리 단일 값만이 있는 경우 `onSuccess`만이 호출되며, `onComplete`는 호출되지 않습니다.

이 새로운 기본 리액티브 타입은 0개 또는 1개의 항목에 동작하는 `Flowable` 오퍼레이터의 적당한 서브셋을 제공하므로 다른 타입과 실질적으로 같습니다.

{% highlight java %}
Maybe.just(1)
    .map(v -> v + 1)
    .filter(v -> v == 1)
    .defaultIfEmpty(2)
    .test()
    .assertResult(2);
{% endhighlight %}

## 기본 리액티브 인터페이스

Reactive-Streams `Publisher`를 `Flowable`로 확장하는 스타일에 따라서, 다른 기본 리액티브 클래스들은 이제 `io.reactivex` 패키지 안에 있는 비슷한 베이스 인터페이스를 상속받게 됩니다.

{% highlight java %}
interface ObservableSource<T> {
    void subscribe(Observer<? super T> observer);
}

interface SingleSource<T> {
    void subscribe(SingleObserver<? super T> observer);
}

interface CompletableSource {
    void subscribe(CompletableObserver observer);
}

interface MaybeSource<T> {
    void subscribe(MaybeObserver<? super T> observer);
}
{% endhighlight %}

따라서 사용자의 일부 기본 리액티브 타입을 인자로 받는 많은 오퍼레이터가 이제 `Publisher`와 `XSource`를 지원합니다.  

{% highlight java %}
Flowable<R> flatMap(Function<? super T, ? extends Publisher<? extends R>> mapper);

Observable<R> flatMap(Function<? super T, ? extends ObservableSource<? extends R>> mapper);
{% endhighlight %}

`Publisher`를 이런 방식으로 입력하면 다른 Reactive-Streams에 호환되는 라이브러리를 랩핑하거나, Flowable로 변환할 필요 없이 작성할 수 있습니다.

그러나 오퍼레이터가 기본 리액티브 타입을 제공해야하는 경우, 사용자는 전체 리액티브 클래스를 받게 됩니다. (`XSource`를 제공하는 것은 오퍼레이터가 없으므로 실질적으로 쓸모가 없습니다.)

{% highlight java %}
Flowable<Flowable<Integer>> windows = source.window(5);

source.compose((Flowable<T> flowable) -> 
    flowable
        .subscribeOn(Schedulers.io())
        .observeOn(AndroidSchedulers.mainThread()));
{% endhighlight %}

## Subject와 Processor

Reactive-Streams 사양에서 이벤트의 소비자이면서 동시에 공급자이기도 한 `Subject`와 비슷한 동작들은 `org.reactivestream.Processor` 인터페이스에 의해 수행됩니다. `Observable`과 `Flowable`의 분리와 마찬가지로, Backpressure와 Reactive-Streams 사양을 준수한 구현은 `FlowableProcessor` 클래스를 기반으로 합니다. (`Flowable`을 확장하여 풍부한 인스턴스 내 오퍼레이터를 제공합니다.) `Subject`에서 중요한 변화는 더는 `T -> R`과 같은 변환을 지원하지 않은 것입니다. (입력 타입이 T이고 출력 타입이 R 유형임을 뜻합니다.) (우리는 1.x에서 이 클래스를 사용하지 못했고, 원래 `Subject`는 .NET에서 왔는데 .NET에서는 같은 클래스 이름에 다른 수의 타입 인자를 둘 수 있어 오버로드가 있었습니다.)

다음 클래스들 `io.reactivex.subjects.AsyncSubject`, `io.reactivex.subjects.BehaviorSubject`, `io.reactivex.subjects.PublishSubject`, `io.reactivex.subjects.ReplaySubject`, `io.reactivex.subjects.UnicastSubject`은 RxJava 2.x에서 Backpressure를 지원하지 않습니다. (2.x의 `Observable` 계열의 일부로서)

다음 클래스들 `io.reactivex.processors.AsyncProcessor`, `io.reactivex.processors.BehaviorProcessor`, `io.reactivex.processors.PublishProcessor`, `io.reactivex.processors.ReplayProcessor`, `io.reactivex.processors.UnicastProcessor`는 Backpressure를 쓸 수 있습니다. `BehaviorProcessor`와 `PublishProcessor`는 다운스트림 Subscriber의 요청을 조정하지 않으며(`Flowable.publish()`를 씁니다.), 다운스트림이 계속 유지될 수 없을 때 `MissingBackpressureException`으로 알려줍니다. 다른 `XProcessor` 타입들은 다운스트림 Subscriber의 Backpressure를 존중하지만, 소스를 subscribe할 때(선택 사항) 무제한적으로 소비하게 됩니다. (`Long.MAX_VALUE`를 요청합니다.) 

## TestSubject

1.x에 있었던 `TestSubject`가 삭제되었습니다. 이 기능은 `TestScheduler`, `PublishProcessor`/`PublishSubject`와 `observeOn(testScheduler)`/scheduler 파라미터를 통해 수행할 수 있습니다.

{% highlight java %}
TestScheduler scheduler = new TestScheduler();
PublishSubject<Integer> ps = PublishSubject.create();

TestObserver<Integer> ts = ps.delay(1000, TimeUnit.MILLISECONDS, scheduler)
    .test();

ts.assertEmpty();

ps.onNext(1);

scheduler.advanceTimeBy(999, TimeUnit.MILLISECONDS);

ts.assertEmpty();

scheduler.advanceTimeBy(1, TimeUnit.MILLISECONDS);

ts.assertValue(1);
{% endhighlight %}

## 다른 클래스들

`rx.observables.ConnectableObservable` 는 이제 `io.reactivex.observables.ConnectableObservable`와 `io.reactivex.flowables.ConnectableFlowable`로 바뀌었습니다.

### GroupedObservable

기존 `rx.observables.GroupedObservable`는 `io.reactivex.observables.GroupedObservable`와 `io.reactivex.flowables.GroupedFlowable`로 바뀌었습니다.

1.x에서는 `GroupedObservable.from()`을 통해 인스턴스를 생성할 수 있었습니다. 2.x에서는 팩토리 메소드가 더는 제공되지 않기 때문에 `GroupedObservable`을 직접 확장해서 써야합니다. 전체 클래스는 추상화되었습니다.

다음과 같이 클래스를 확장하고 사용자가 정의한 `subscribeActural` 동작을 추가하여 1.x와 유사한 기능을 구현할 수 있습니다.

{% highlight java %}
class MyGroup<K, V> extends GroupedObservable<K, V> {
    final K key;

    final Subject<V> subject;

    public MyGroup(K key) {
        this.key = key;
        this.subject = PublishSubject.create();
    }

    @Override
    public T getKey() {
        return key;
    }

    @Override
    protected void subscribeActual(Observer<? super T> observer) {
        subject.subscribe(observer);
    }
}
{% endhighlight %}

(`GroupedFlowable`도 비슷한 방법으로 이용할 수 있습니다.)

## 함수형 인터페이스

1.x와 2.x 모두 Java 6+를 대상으로 하므로 우리는 `java.util.function.Function`과 같은 Java 8의 함수형 인터페이스를 사용할 수 없습니다. 하지만 우리는 자체적인 함수형 인터페이스를 1.x에서 구현했으며, 2.x에서도 그 전통을 따랐습니다.

주목할만한 차이점은 이제 우리의 모든 함수형 인터페이스에 `throws Exception`가 붙었습니다. 더는 `try-catch` 문으로 감싸거나, 검사 예외를 바꿀 필요가 없으므로 소비자와 매퍼에 큰 편의를 제공합니다.

{% highlight java %}
Flowable.just("file.txt")
    .map(name -> Files.readLines(name))
    .subscribe(lines -> System.out.println(lines.size()), Throwable::printStackTrace);
{% endhighlight %}

파일이 없거나 제대로 읽을 수 없을 때, 최종 사용자는 `IOException`을 직접 출력합니다. try-catch 없이 호출된 `Files.readLines(name)`에 주목해주세요.

## Action

컴포넌트 수를 줄일 수 있는 좋은 기회이기 때문에, 2.x에서는 `Action3`-`Action9`와  `ActionN`(RxJava 자체에서는 사용되지 않음)이 빠지게 되었습니다. 

나머지 액션 인터페이스들은 Java 8의 함수형 타입에 따라 이름이 바뀌었습니다. 매개변수가 없는 `Action0`은 `io.reactivex.functions.Action`으로 바뀌었으며, `Scheduler` 메소드에 대한 `java.lang.Runnable`로 대체됩니다. `Action1`은 `Consumer`로, `Action2`는 `BiConsumer`로 이름이 바뀌었습니다. `ActionN`은 `Consumer<Object[]>` 타입 선언으로 대체됩니다.

### Function

우리는 Java 8의 네이밍 컨벤션에 맞춰 `io.reactivex.functions.Function`과 `io.reactivex.functions.BiFunction`을 정의했으며, `Func3` - `Func9`를 각각  `Function3` - `Function9`로 바꿨습니다. `FuncN`은 `Function`  타입 선언으로 대체됩니다.

또한 서술을 필요로 하는 오퍼레이터는 더는 `Func1<T, Boolean>`를 사용하지 않고 별도의 기본 반환 타입인 `Predicate<T>`를 가집니다. (오토박싱이 없으므로 더 좋은 인라인이 가능합니다.)

`io.reactivex.functions.Functions` 유틸리티 클래스는 일반적인 함수 소스와 `Function<Object[], R>`으로의 변환을 제공합니다.

## Subscriber

Reactive-Streams 사양에는 Subscriber가 자체 인터페이스로 있습니다. 이 인터페이스는 가볍고 요청 관리와 취소를`rx.Producer`와 `rx.Subscription`을 별도로 갖는 대신 하나의 인터페이스인 `org.reactivestreams.Subscription`로 합쳐서 사용합니다. 이렇게 하면 1.x의 무거운 `rx.Subscriber`보다 내부 상태가 적은 스트림 소비자를 생성할 수 있습니다.

{% highlight java %}
Flowable.range(1, 10).subscribe(new Subscriber<Integer>() {
    @Override
    public void onSubscribe(Subscription s) {
        s.request(Long.MAX_VALUE);
    }

    @Override
    public void onNext(Integer t) {
        System.out.println(t);
    }

    @Override
    public void onError(Throwable t) {
        t.printStackTrace();
    }

    @Override
    public void onComplete() {
        System.out.println("Done");
    }
});
{% endhighlight %}

이름이 충돌하므로 패키지를 `rx`에서 `org.reactivestreams`로 바꾸는 것만으로는 충분하지 않습니다. 또한 `org.reactivestreams.Subscriber`는 리소스를 추가하거나 취소하거나 외부에서 요청하는 개념을 가지고 있지 않습니다.

이 격차을 메우기 위해 `rx.Subscriber`와 마찬가지로 `Disposable`들의 리소스 추적 지원을 제공하고, `dispose()`를 통해 외부에서 취소하거나 정리할 수 있는 `Flowable`(과 `Observable`)을 위한 추상 클래스 `DefaultSubscriber`, `ResourceSubscriber`, `DisposableSubscriber`(`XObserver` 변형 포함)를 정의했습니다.

{% highlight java %}
ResourceSubscriber<Integer> subscriber = new ResourceSubscriber<Integer>() {
    @Override
    public void onStart() {
        request(Long.MAX_VALUE);
    }

    @Override
    public void onNext(Integer t) {
        System.out.println(t);
    }

    @Override
    public void onError(Throwable t) {
        t.printStackTrace();
    }

    @Override
    public void onComplete() {
        System.out.println("Done");
    }
};

Flowable.range(1, 10).delay(1, TimeUnit.SECONDS).subscribe(subscriber);

subscriber.dispose();
{% endhighlight %}

또한 Reactive-Streams와의 호환을 위해 `onCompleted` 메소드는 뒤에 `d`가 빠진 `onComplete`로 이름이 바뀌었습니다.

1.x에서 `Observable.subscribe(Subscriber)`는 `Subscription`을 반환했는데, 사용자들은 `Subscription`을 다음과 같이 `CompositeSubscription`에 추가했었습니다.

{% highlight java %}
CompositeSubscription composite = new CompositeSubscription();

composite.add(Observable.range(1, 5).subscribe(new TestSubscriber<Integer>()));
{% endhighlight %}

Reactive-Streams 사양에 따라 `Publisher.subscribe`는 void를 반환하므로 이런 패턴은 2.0에서는 더는 작동하지 않습니다. 이를 해결하기 위해 `E subscribeWith(E subscriber)` 메소드가 입력받은 구독자와 관찰자를 그대로 반환하는 각 기본 리액티브 클래스에 추가되었습니다. `ResourceSubscriber`가 `Disposable`을 직접 구현하므로 이전의 두 예제를 사용하면 2.x 코드는 다음과 같이 보입니다.

{% highlight java %}
CompositeDisposable composite2 = new CompositeDisposable();

composite2.add(Flowable.range(1, 5).subscribeWith(subscriber));
{% endhighlight %}

### onSubscribe/onStart에서 request 호출하기

요청 관리가 어떻게 작동하는지에 따라 `Subscriber.onSubscribe`나 `ResourceSubscriber.onStart`에서 `request(n)`을 호출하면 `request()` 호출 자체가 자신의 `onSubscribe`/`onStart` 메소드로 돌아가기 전에 `onNext`를 즉시 호출하도록 유도할 수 있습니다.

{% highlight java %}
Flowable.range(1, 3).subscribe(new Subscriber<Integer>() {

    @Override
    public void onSubscribe(Subscription s) {
        System.out.println("OnSubscribe start");
        s.request(Long.MAX_VALUE);
        System.out.println("OnSubscribe end");
    }

    @Override
    public void onNext(Integer v) {
        System.out.println(v);
    }

    @Override
    public void onError(Throwable e) {
        e.printStackTrace();
    }

    @Override
    public void onComplete() {
        System.out.println("Done");
    }
});
{% endhighlight %}

이는 다음과 같이 출력될 것입니다.

{% endhighlight %}
OnSubscribe start
1
2
3
Done
OnSubscribe end
{% endhighlight %}

문제는 `request`를 호출한 뒤  `onSubscribe/onStart`에서 초기화를 수행할 때 문제가 발생하고, `onNext`는 초기화의 결과를 볼 수도 있고 보지 않을 수도 있습니다. 이 상황을 피하려면 onSubscribe / onStart에서 **모든 초기화가 완료된 후**에 request를 호출해야 합니다.

2.x에서 이 동작은 `request` 호출이 업스트림 `Producer`가 도착할 때까지 지연 로직을 거쳐 요청을 축적한 1.x와는 다릅니다. (이 특성은 1.x의 모든 오퍼레이터와 소비자에 오버헤드를 더합니다.) 2.x에서는 항상 `Subscription`은 첫 번째로 내려가고, 90%는 요청을 연기할 필요가 없습니다.

## Subscription

RxJava 1.x에서 `rx.Subscription` 인터페이스는 스트림 및 리소스의 라이프사이클 관리, 즉 시퀀스의 구독을 취소하고 예약된 작업과 같은 일반적인 리소스를 해제합니다. Reactive-Streams 사양은 소스와 소비자 간의 상호작용 지점을 지정하기 위해 이 이름을 사용했습니다. `org.reactivestreams.Subscription`을 사용하면 업스트림에서 요청할 수 있으며 시퀀스를 취소할 수 있습니다.

이름 충돌을 피하기 위해 1.x의 `rx.Subscription`은 `io.reactivex.Disposable`(.NET의 IDisposable과 비슷함)으로 이름이 바뀌었습니다.

왜냐하면, Reactive-Streams의 기본 인터페이스 `org.reactivestreams.Publisher`는 `subscribe()` 메소드를 void로 정의했기 때문입니다. `Flowable.subscribe(Subscriber)`는 더는 어떠한 `Subscription`이나 `Disposable`을 반환하지 않습니다. 다른 기본 리액티브 타입들도 각각의 구독자 타입에 따라 이 규칙을 따릅니다.

`subscribe`의 다른 오버로드는 2.x에서 `Disposable`을 반환합니다.

원래의 `Subscription` 컨테이너 타입들은 이름이 바뀌고 새로워졌습니다.

- `CompositeSubscription`은 `CompositeDisposable`로 바뀌었습니다.
- `SerialSubscription`와 `MultipleAssignmentSubscription`는 `SerialDisposable`로 합쳐졌습니다. `set()` 메소드는 오래된 값을 정리하며 `replace()` 메소드는 정리하지 않습니다.
- `RefCountSubscription`는 삭제되었습니다.

## Backpressure

Reactive-Streams의 사양은 Backpressure를 지원하는 연산자를 요구합니다. 특히 Backpressure를 요구하지 않을 때 소비자가 넘치지 않도록 보장해줍니다. 새로운 `Flowable` 기본 리액티브 타입의 오퍼레이터는 이제 다운스트림 요청량을 적절하게 고려하지만 `MissingBackpressureException`이 완전히 사라진 것은 아닙니다. 이런 익셉션은 여전히 존재하지만 이번에는 더 많은 신호를 보낼 수 없는 오퍼레이터가 대신 익셉션을 알립니다. (이를 통해 제대로 Backpressure 되지 않은 부분을 더 잘 식별할 수 있습니다.)

대안으로 2.x의 `Observable`은 전혀 Backpressure를 하지 않으며, 선택의 여지가 있습니다.

## Reactive-Streams 호환

Flowable에 기반을 둔 소스와 오퍼레이터는 규칙 §3.9와 규칙 §1.3의 한 해석을 제외하고 Reactive-Streams 1.0.0 규격을 준수합니다.

> §3.9: Subscription이 취소되지 않은 동안 Subscription.request(long n)은 인수가 <= 0인 경우 무조건 java.lang.IllegalArgumentException으로 onError를 호출합니다. 에러 메시지에는 이 규칙에 대한 참조가 무조건 포함되어야만 합니다. 그리고 선택적으로 전체 규칙에 대한 인용이 포함될 수 있습니다.

규칙 §3.9는 버그 케이스에 대처하기 위해 과도한 오버헤드(`request()`를 처리하는 **모든** 오퍼레이터에 대한 half-serializer)가 필요합니다. RxJava 2(와 Reactor 3)는 `RxJavaPlugins.onError`에 `IllegalArgumentException`을 보고하고, 그렇지 않으면 무시합니다. RxJava 2는 `IllegalArgumentException`을 비동기식으로 `Subscriber.onError`에 라우팅하는 [사용자 지정 오퍼레이터](https://github.com/ReactiveX/RxJava/blob/2.x/src/test/java/io/reactivex/tck/FlowableTck.java)를 적용하여 TCK(Test Compatibility Kit)를 전달합니다. 모든 주요 Reactive-Streams 라이브러리에는 이러한 제로 요청이 없습니다. Reactor 3은 이를 무시하고, Akka-Stream은 TCK 오퍼레이터와 비슷한 라우팅 동작을 가진 변환기(다른 RS 소스 및 소비자와 상호작용하기 위해)를 사용합니다.

> §1.3: onSubscribe, onNext, onError, onComplete는 구독자에게 순차적으로 신호를 보내야 합니다. (동시에 알림을 보낼 수 없습니다.)

TCK는 `onSubscribe`와 `onNext`간에 동기식이지만 제한된 재진입을 허용합니다. 즉, `onSubscribe`에 있는동안 `request(1)` 호출은 `onSubscribe`가 제어를 반환하지 않고도 `onNext`를 호출할 수 있습니다. 거의 모든 오퍼레이터가 이러한 방식으로 동작하지만 오퍼레이터 `observeOn`은 `request(1)`에 대한 응답으로 `onNext`를 비동기적으로 호출할 수 있으므로 `onSubscribe`가 `onNext`와 동시에 실행됩니다. 이것은 TCK에 의해 확률적으로 탐지되며 `onSubscribe`가 반환될 때까지 다운스트림 요청을 연기하는 [다른 오퍼레이터](https://github.com/ReactiveX/RxJava/blob/2.x/src/test/java/io/reactivex/tck/FlowableAwaitOnSubscribeTck.java)를 사용합니다. 이 비동기 동작은 RxJava 2 및 Reactor 3에서 문제가 되지 않습니다. 연산자는 `onSubscribe` 안에서 스레드에 안전한 방식으로 작업을 수행하고, Akka-Stream의 변환기는 비슷한 지연된 요청 관리를 수행하기 때문입니다.

이 두 동작은 라이브러리 간의 동작에 영향을 주기 때문에 버전 2.0.5에서는 `strict()` 오퍼레이터가 도입되고 항목 당 오버헤드를 희생시키면서 이러한 규칙과 몇가지 추가 규칙이 적용됩니다.

## 런타임 훅

2.x에서는 런타임 시 훅을 변경할 수 있는 `RxJavaPlugins`를 다시 디자인했습니다. 스케줄러와 기본 리액티브 타입의 라이프사이클을 오버라이드하려는 테스트는 콜백 함수를 통해 사례별로 수행할 수 있습니다.

클래스에 기반을 둔 `RxJavaObservableHook` 및 친구들은 이제 없어졌으며 `RxJavaHooks`의 기능들은 `RxJavaPlugins` 에 흡수되었습니다.

## 에러 처리

2.x에서의 중요한 설계 요구사항 중 하나는 `Throwable` 에러를 무시해서는 안된다는 것입니다. 이것은 다운스트림의 라이프사이클이 이미 터미널 상태에 도달했거나 다운스트림이 에러를 방출하려고 했던 시퀀스를 취소했기 때문에 방출할 수 없는 에러를 의미합니다.

이러한 에러들은 `RxJavaPlugins.onError` 핸들러로 전달됩니다. 이 핸들러는 `RxJavaPlugins.setErrorHandler(Consumer)` 메소드로 오버라이드할 수 있습니다. 특정 핸들러가 없으면 RxJava는 기본적으로 Throwable의 스택 추적을 콘솔에 출력하고 현재 스레드의 포착되지 않은 예외 핸들러를 호출합니다.

데스크톱 자바에서 이 후처리기는 Executer-Service 기반 Scheduler에서 아무런 작업도 수행하지 않고 애플리케이션을 계속 실행합니다. 그러나 Android는 더 엄격하고 예기치 못한 예외 상황에서 애플리케이션을 종료합니다.

이 동작이 바람직할 경우 논쟁의 여지가 있지만, 어쨌든 잡히지 않은 에러 핸들러의 호출을 피하려면 RxJava 2를 사용하는 **최종 응용 프로그램**(직접 혹은 간접적으로)에 no-op 핸들러를 설정해야 합니다.

{% highlight java %}
// 자바 8의 람다식을 쓸 수 있을 때
RxJavaPlugins.setErrorHandler(e -> { });

// Retrolambda나 Jack을 쓸 수 없을 때
RxJavaPlugins.setErrorHandler(Functions.<Throwable>emptyConsumer());
{% endhighlight %}

중간 라이브러리가 자체 테스트 환경 밖에서 에러 핸들러를 변경하는 것은 권장되지 않습니다.

## Scheduler

2.x API에서도 `io.reactivex.schedulers.Schedulers` 유틸리티 클래스를 통해 계속 `computation`, `io`, `newThread`, `trampoline` 등의 기본 스케줄러 타입을 지원합니다. 

`immediate` 스케줄러는 2.x에서 없어졌습니다. 그것은 종종 잘못 사용되었고 `Scheduler`의 스펙을 올바르게 구현하지 못했습니다. 그것은 지연된 행동에 대한 sleep을 차단하는 것을 포함하며 재귀적 스케줄링을 전혀 지원하지 않았습니다. 대신 `Schedulers.trampoline()`을 사용하십시오.

`Schedulers.test()`는 나머지 기본 스케줄러와의 개념 상의 차이를 피하기 위해 없어졌습니다. 그것들은 "글로벌" 스케줄러 인스턴스를 리턴하지만 `test()`는 항상 `TestScheduler`의 새로운 인스턴스를 리턴합니다. 테스트가 필요한 개발자는 이제 코드에서 단순히 `new TestScheduler()`를 사용하면 됩니다.

`io.reactivex.Scheduler` 추상 기본 클래스는 이제 `Worker`(자주 잊어버릴 수 있습니다.)를 생성하고 제거할 필요 없이 직접 태스크를 스케쥴링합니다.

{% highlight java %}
public abstract class Scheduler {

    public Disposable scheduleDirect(Runnable task) { ... }

    public Disposable scheduleDirect(Runnable task, long delay, TimeUnit unit) { ... }

    public Disposable scheduleDirectPeriodically(Runnable task, long initialDelay, 
        long period, TimeUnit unit) { ... }

    public long now(TimeUnit unit) { ... }

    // ... 나머지는 비슷합니다: 라이프사이클 메소드나, Worker의 생성이나...
}
{% endhighlight %}

주된 목적은 일반적으로 한번에 끝날 수 있는 작업에 대한 `Worker`의 추적 오버헤드를 피하는 것입니다. 이 메소드는 `createWorker`를 적절하게 재사용하는 기본 구현을 가지고 있지만 필요하다면 더욱 효율적인 구현으로 오버라이드할 수 있습니다.

스케줄러 자신의 현재 시각을 반환하는 메소드 `now()` 는 이제 시간의 측정 단위를 나타내기 위해 `TimeUnit`을 받을 수 있게끔 바뀌었습니다.

## 리액티브 세계로 들어가기

RxJava 1.x의 설계 결함 중 하나는 `rx.Observable.create()` 메소드가 노출된 것입니다. 이는 리액티브 세계에 들어가기 위해 사용하는 일반적인 연산자가 아닙니다. 불행히도 많은 사람들이 그것을 제거하거나 이름을 바꿀 수 없다는 사실에 의존하고 있습니다.

2.x부터는 새로운 출발이므로, 우리는 그런 실수를 반복하지 않을 것입니다. 각 리액티브 기본 타입인 `Flowable`, `Observable`, `Single`, `Maybe`, `Completable`은 Backpressure(`Flowable`만 해당)와 취소에 대한 올바른 작업을 수행하는 안전한 `create` 오퍼레이터를 특징으로 합니다.

{% highlight java %}
Flowable.create((FlowableEmitter<Integer> emitter) -> {
    emitter.onNext(1);
    emitter.onNext(2);
    emitter.onComplete();
}, BackpressureStrategy.BUFFER);
{% endhighlight %}

실제로는 1.x의 `fromEmitter`(이전의 `fromAsync`)는 `Flowable.create`로 이름이 바뀌었습니다. 다른 기본 리액티브 타입들도 유사한 `create` 메소드를 가지고 있습니다. (Backpressure 전략을 제외한)

## 리액티브 세계에서 떠나기

각각의 소비자(`Subscriber`, `Observer`, `SingleObserver`, `MaybeObserver`, `CompletableObserver`)와 함수형 인터페이스에 기반을 둔 소비자(`subscribe(Consumer, Consumer, Action)`와 같은 것들)를 통해 기본 유형들을 구독하는 것과는 달리, 이전에는 1.x에선 별개로 있었던 `BlockingObservable`(와 비슷한 다른 클래스들)이 주요 리액티브 타입과 통합되었습니다. 이제 `blockingX` 연산을 직접 호출하여 몇가지 결과들을 직접 블로킹할 수 있습니다.

{% highlight java %}
List<Integer> list = Flowable.range(1, 100).toList().blockingGet(); // toList() returns Single

Integer i = Flowable.range(100, 100).blockingLast();
{% endhighlight %}

(그 이유는 성능과 동기식 Java 8 Streams와 비슷한 프로세서 라이브러리를 쓰는 것에 대한 용이함 때문입니다.)

또 다른 2.x에서 `rx.Subscriber`와 `org.reactivestreams.Subscriber`의 차이점은 여러분의 `Subscriber`와 `Observer`는 치명적인 예외를 발생하는 것을 허용하지 않는다는 점입니다.(`Exceptions.throwIfFatal()`을 보세요.) (Reactive-Streams 사양은 `onSubscribe`, `onNext`, `onError`가 null 값을 받으면 `NullPointerException`을 날릴 수 있지만 RxJava는 `null`을 허용하지 않습니다.) 이는 다음 코드는 더는 유효하지 않다는 것을 뜻합니다.

{% highlight java %}
Subscriber<Integer> subscriber = new Subscriber<Integer>() {
    @Override
    public void onSubscribe(Subscription s) {
        s.request(Long.MAX_VALUE);
    }

    public void onNext(Integer t) {
        if (t == 1) {
            throw new IllegalArgumentException();
        }
    }

    public void onError(Throwable e) {
        if (e instanceof IllegalArgumentException) {
            throw new UnsupportedOperationException();
        }
    }

    public void onComplete() {
        throw new NoSuchElementException();
    }
};

Flowable.just(1).subscribe(subscriber);
{% endhighlight %}

같은 것들이 `Observer`, `SingleObserver`, `MaybeObserver`, `CompletableObserver`에도 적용되었습니다.

1.x를 타겟으로하는 많은 기존 코드가 그런 일을 하므로, 이러한 기준에 적합하지 않은 소비자를 처리하는 `safeSubscribe` 메소드가 도입되었습니다.

또는, `subscribe (Consumer, Consumer, Action)`(와 유사한) 메소드를 사용하여 다음을 던질 수 있는 콜백 혹은 람다식을 제공할 수 있습니다.

{% highlight java %}
Flowable.just(1).subscribe(
    subscriber::onNext, 
    subscriber::onError, 
    subscriber::onComplete, 
    subscriber::onSubscribe
);
{% endhighlight %}

## 테스팅

RxJava 2.x 테스트는 1.x에서와 같은 방식으로 작동합니다. `Flowable`은`io.reactivex.subscribers.TestSubscriber`로 테스트 할 수 있습니다. 반면에`Observable`, `Single`, `Maybe`, `Completable`은`io.reactivex.observers.TestObserver`로 테스트 할 수 있습니다.

### test() "오퍼레이터"

우리의 내부 테스트를 지원하기 위해, 모든 기본 리액티브 타입은 이제 `TestSubscriber` 또는`TestObserver`를 반환하는 `test()`메소드를 제공합니다.

{% highlight java %}
TestSubscriber<Integer> ts = Flowable.range(1, 5).test();

TestObserver<Integer> to = Observable.range(1, 5).test();

TestObserver<Integer> tso = Single.just(1).test();

TestObserver<Integer> tmo = Maybe.just(1).test();

TestObserver<Integer> tco = Completable.complete().test();
{% endhighlight %}

두 번째 편리함은 대부분의 `TestSubscriber`/`TestObserver` 메소드가 인스턴스 자체를 반환하여 다양한 `assertX` 메소드와 연결될 수 있다는 것입니다. 세 번째 편리함은 코드에서 `TestSubscriber` / `TestObserver` 인스턴스를 생성하거나 삽입하지 않고 소스를 자유롭게 테스트할 수 있다는 것입니다.

{% highlight java %}
Flowable.range(1, 5)
	.test()
	.assertResult(1, 2, 3, 4, 5);
{% endhighlight %}

#### 주목할만한 새로운 단언문 메소드

- `assertResult(T... items)`: 구독할 때 지정된 순서로 지정된 항목을 정확히 수신한 뒤 에러 없이 `onComplete` 되는 것을 단언합니다.
- `assertFailure(Class clazz, T... items)`: 구독할 때 지정된 순서로 지정된 항목을 정확히 수신한 뒤, `clazz.isInstance()`를 만족하는 `Throwable` 에러를 수신하는걸 단언합니다.
- `assertFailureAndMessage(Class clazz, String message, T... items)`: `assertFailure`와 비슷한 역할을 하며, `getMessage()`를 통해 특정 에러 메시지를 validation 하는 기능이 더해졌습니다.
- `awaitDone(long time, TimeUnit unit)`은 블로킹 방식으로 터미널 이벤트를 기다리고, 타임아웃이 경과하면 시퀀스를 취소합니다.
- `assertOf(Consumer> consumer)`는 단언문을 자연스러운 체인에 구성합니다. (오퍼레이터 결합이 현재 아직 공개된 API가 아니기 때문에 결합 테스트를 위해 내부적으로 사용됩니다.)

`Flowable`을 `Observable`로 변경하면서 생기는 이점 중 하나는 `TestSubscriber`를 `TestObserver`로 암시적으로 변경했기 때문에, 테스트 코드를 전혀 변경할 필요가 없다는 것입니다.

### 취소와 먼저 요청하기

`TestObserver`에 있는 `test()` 메소드는 `test(boolean cancel)`을 오버로드해, 구독하기도 전에 `TestSubscriber`/`TestObserver`를 취소하거나 정리합니다.

{% highlight java %}
PublishSubject<Integer> pp = PublishSubject.create();

// 아직 아무도 구독하지 않았음
assertFalse(pp.hasSubscribers());

pp.test(true);

// 여전히 아무도 구독하지 않았음
assertFalse(pp.hasSubscribers());
{% endhighlight %}

`TestSubscriber`는 `test(long initialRequest)`와 `test(long initialRequest, boolean cancel)` 오버로드로 처음 요청할 양을 지정하고, `TestSubscriber`도 즉시 취소해야하는지 여부를 지정합니다.  `initialRequest`가 주어지면 `TestSubscriber` 인스턴스는 `request()` 메소드에 접근하기 위해 캡쳐해야 합니다.

{% highlight java %}
PublishProcessor<Integer> pp = PublishProcessor.create();

TestSubscriber<Integer> ts = pp.test(0L);

ts.request(1);

pp.onNext(1);
pp.onNext(2);

ts.assertFailure(MissingBackpressureException.class, 1);
{% endhighlight %}

### 비동기 소스를 테스팅하기

비동기 소스가 주어지면 터미널 이벤트를 자연스럽게 차단할 수 있습니다.

{% highlight java %}
Flowable.just(1)
  .subscribeOn(Schedulers.single())
  .test()
  .awaitDone(5, TimeUnit.SECONDS)
  .assertResult(1);
{% endhighlight %}

### Mockito와 TestSubscriber

Mockito를 사용하고, 1.x에서 모킹된 Observer를 쓰는 사람들은 `Subscriber.onSubscribe` 메소드를 모킹해서 초기 요청을 보내야 합니다. 그렇지 않으면 시퀀스가 멈추거나, 핫 소스와 함께 실패하게 됩니다.

{% highlight java %}
@SuppressWarnings("unchecked")
public static <T> Subscriber<T> mockSubscriber() {
    Subscriber<T> w = mock(Subscriber.class);

    Mockito.doAnswer(new Answer<Object>() {
        @Override
        public Object answer(InvocationOnMock a) throws Throwable {
            Subscription s = a.getArgumentAt(0, Subscription.class);
            s.request(Long.MAX_VALUE);
            return null;
        }
    }).when(w).onSubscribe((Subscription)any());

    return w;
}
{% endhighlight %}

## 오퍼레이터 변경 사항

대부분의 오퍼레이터는 2.x에서 여전히 사용되고 있으며 거의 모든 오퍼레이터는 1.x에서와 비슷하게 동작합니다. 다음 하위 섹션에서는 각 기본 리액티브 타입과 1.x와 2.x에서의 차이점이 나와있습니다.

일반적으로 많은 오퍼레이터가 업스트림(또는 내부 소스)을 실행해야 하는 내부 버퍼 크기 또는 pre-fetch 양을 지정할 수 있게 되어 오버로드가 늘었습니다.

일부 연산자 오버로드는 `fromArray`, `fromIterable` 등과 같이 접미사를 포함해 이름이 바뀌었습니다. 그 이유는 라이브러리가 Java 8로 컴파일 될 때, javac가 함수형 인터페이스 타입을 명확하게 파악할 수 없기 때문입니다.

1.x에서 `@Beta`나 `@Experimental`였던 오퍼레이터들은 이제 표준이 되었습니다.

### 1.x Observable에서 2.x Flowable로

#### 팩토리 메소드:

| 1.x                        | 2.x                                      |
| -------------------------- | ---------------------------------------- |
| `amb`                      | `amb(ObservableSource...)`  오버로드가 추가되고, 인자가 2-9개인 버전이 삭제되었습니다. |
| RxRingBuffer.SIZE          | `bufferSize()`                           |
| `combineLatest`            | 가변인자 오버로드가 추가되었습니다. `bufferSize` 인자에 대한 오버로드가 추가되었고, `combineLatest(List)`가 없어졌습니다. |
| `concat`                   | `prefetch`에 대한 오버로드가 추가되었습니다. 5-9 소스에 대한 오버로드가 없어졌습니다, 대신 `concatArray`를 쓰세요. |
| N/A                        | `concatArray`와  `concatArrayDelayError`가 추가되었습니다. |
| N/A                        | `concatArrayEager`와 `concatArrayEagerDelayError`가 추가되었습니다. |
| `concatDelayError`         | 끝날 때까지, 또는 끝까지 지연시키는 옵션에 대한 오버로드가 추가되었습니다. |
| `concatEagerDelayError`    | 끝날 때까지, 또는 끝까지 지연시키는 옵션에 대한 오버로드가 추가되었습니다. |
| `create(SyncOnSubscribe)`  | `generate`로 바뀌었습니다. 인터페이스의 변경으로 한번에 구현할 수 있게 되었습니다. 이에 대한 오버로드가 추가되었습니다. |
| `create(AsnycOnSubscribe)` | 변경 사항이 없습니다.                             |
| `create(OnSubscribe)`      | 안전한 `create(FlowableOnSubscribe, BackpressureStrategy)`으로 목적이 바뀌었습니다. raw 형태의 지원은 `unsafeCreate()`를 이용합니다.. |
| `from`                     | `fromArray`, `fromIterable`, `fromFuture`로 모호함을 없앴습니다. |
| N/A                        | `fromPublisher`가 추가되었습니다.                |
| `fromAsync`                | `create()`로 이름이 바뀌었습니다.                  |
| N/A                        | `intervalRange()`가 추가되었습니다.              |
| `limit`                    | 없어졌습니다. 대신 `take`를 쓰세요.                  |
| `merge`                    | `prefetch`에 대한 오버로드가 추가되었습니다.            |
| `mergeDelayError`          | `prefetch`에 대한 오버로드가 추가되었습니다.            |
| `sequenceEqual`            | `bufferSize`에 대한 오버로드가 추가되었습니다.          |
| `switchOnNext`             | `prefetch`에 대한 오버로드가 추가되었습니다.            |
| `switchOnNextDelayError`   | `prefetch`에 대한 오버로드가 추가되었습니다.            |
| `timer`                    | 사용하지 않게 된 오버로드를 없앴습니다.                   |
| `zip`                      | `bufferSize`와  `delayErrors` 가능성에 대한 오버로드가 추가되었습니다. `zipArray`, `zipIterable`와의 모호함을 없앴습니다. |

#### 인스턴스 메소드:

| 1.x                                 | 2.x                                      |
| ----------------------------------- | ---------------------------------------- |
| `all`                               | **RC3**부터는 `Single`을 반환합니다.              |
| `any`                               | **RC3**부터는 `Single`을 반환합니다.              |
| `asObservable`                      | `hide()`로 바뀌었습니다. 이제 모든 아이덴티티를 숨깁니다.     |
| `buffer`                            | 커스텀 `Collection` 서플라이어에 대한 오버로드가 추가되었습니다. |
| `cache(int)`                        | 사용되지 않으며, 삭제되었습니다.                       |
| `collect`                           | **RC3**부터는 `Single`을 반환합니다.              |
| `collect(U, Action2)`               | `collectInto`와의 모호함을 없애고 **RC3**부터는 `Single`을 반환합니다. |
| `concatMap`                         | `prefetch`에 대한 오버로드가 추가되었습니다.            |
| `concatMapDelayError`               | `prefetch`에 대한 오버로드가 추가되었습니다. 끝날 때까지, 또는 끝까지 지연시키는 옵션에 대한 오버로드가 추가되었습니다. |
| `concatMapEager`                    | `prefetch`에 대한 오버로드가 추가되었습니다.            |
| `concatMapEagerDelayError`          | `prefetch`에 대한 오버로드가 추가되었습니다. 끝날 때까지, 또는 끝까지 지연시키는 옵션에 대한 오버로드가 추가되었습니다. |
| `count`                             | **RC3**부터는 `Single`을 반환합니다.              |
| `countLong`                         | 없어졌습니다. 대신 `count`를 쓰세요.                 |
| `distinct`                          | 커스텀 Collection 서플라이어에 대한 오버로드가 추가되었습니다.  |
| `doOnCompleted`                     | `doOnComplete`로 이름이 바뀌었습니다. `d`가 빠졌다는걸 유의하세요! |
| `doOnUnsubscribe`                   | `Flowable.doOnCancel`와 다른 타입에서는 `doOnDispose`로 바뀌었습니다. [추가 정보](https://github.com/ReactiveX/RxJava/wiki/What's-different-in-2.0#dooncanceldoondisposeunsubscribeon) |
| N/A                                 | `onSubscribe`를 다루고, `request`와 `cancel`를 관찰할 수 있는 `doOnLifecycle`가 추가되었습니다. |
| `elementAt(int)`                    | **RC3**부터는 소스가 인덱스보다 짧은 경우에 `NoSuchElementException`을 내지 않습니다. |
| `elementAt(Func1, int)`             | 없어졌습니다. 대신 `filter(predicate).elementAt(int)`를 쓰세요. |
| `elementAtOrDefault(int, T)`        | `elementAt(int, T)`로 이름이 바뀌었으며 **RC3**부터는 `Single`을 반환합니다. |
| `elementAtOrDefault(Func1, int, T)` | 없어졌습니다. 대신 `filter(predicate).elementAt(int, T)`를 쓰세요. |
| `first()`                           | **RC3**부터 `firstElement`로 이름이 바뀌었으며 `Maybe`를 반환합니다. |
| `first(Func1)`                      | 없어졌습니다. 대신 `filter(predicate).first()`를 쓰세요. |
| `firstOrDefault(T)`                 | `first(T)`로 바뀌었으며 **RC3**부터는 `Single`을 반환합니다. |
| `firstOrDefault(Func1, T)`          | 없어졌습니다. 대신 `filter(predicate).first(T)`를 쓰세요. |
| `flatMap`                           | `prefetch`에 대한 오버로드가 추가되었습니다.            |
| N/A                                 | 조건부로 소비를 중지하기 위한 `forEachWhile(Predicate, [Consumer, [Action]])`이 추가되었습니다. |
| `groupBy`                           | `bufferSize`와 `delayError` 옵션에 대한 오버로드가 추가되었습니다. *커스텀 내부 맵 버전이 RC1에 포함되지 않았습니다.* |
| `ignoreElements`                    | **RC3**부터는 `Completable`을 반환합니다.         |
| `isEmpty`                           | **RC3**부터는 `Single`를 반환합니다.              |
| `last()`                            | **RC3**부터는 `lastElement`로 이름이 바뀌었으며, `Maybe`를 반환합니다. |
| `last(Func1)`                       | 없어졌습니다. 대신 `filter(predicate).last()`를 쓰세요. |
| `lastOrDefault(T)`                  | `last(T)`로 이름이 바뀌었습니다. **RC3**부터는 `Single`을 반환합니다. |
| `lastOrDefault(Func1, T)`           | 없어졌습니다. 대신 `filter(predicate).last(T)`를 쓰세요. |
| `nest`                              | 없어졌습니다. 수동으로 `just`를 쓰세요.                |
| `publish(Func1)`                    | `prefetch`에 대한 오버로드가 추가되었습니다.            |
| `reduce(Func2)`                     | **RC3**부터는 `Maybe`를 반환합니다.               |
| N/A                                 | 가입자-개별(Subscriber-Individual) 방식으로 줄이는 `reduceWith(Callable, BiFunction)`가 추가되었습니다. `Single`을 반환합니다. |
| N/A                                 | `repeatUntil(BooleanSupplier)`가 추가되었습니다. |
| `repeatWhen(Func1, Scheduler)`      | 오버로드가 없어졌습니다. 대신 `subscribeOn(Scheduler).repeatWhen(Function)`를 쓰세요. |
| `retry`                             | `retry(Predicate)`, `retry(int, Predicate)`가 추가되었습니다. |
| N/A                                 | `retryUntil(BooleanSupplier)`가 추가되었습니다.  |
| `retryWhen(Func1, Scheduler)`       | 오버로드가 없어졌습니다. 대신 `subscribeOn(Scheduler).retryWhen(Function)`를 쓰세요. |
| N/A                                 | 가입자-개별(Subscriber-Individual) 방식으로 스캔하는 `sampleWith(Callable, BiFunction)`이 추가되었습니다. |
| `single()`                          | **RC3**부터 `singleElement`로 이름이 바뀌었으며 `Maybe`를 반환합니다. |
| `single(Func1)`                     | 없어졌습니다. 대신 `filter(predicate).single()`을 쓰세요. |
| `singleOrDefault(T)`                | `single(T)`로 이름이 바뀌었으며, **RC3**부터 `Single`을 반환합니다. |
| `singleOrDefault(Func1, T)`         | 없어졌습니다. `filter(predicate).single(T)`를 쓰세요. |
| `skipLast`                          | `bufferSize`, `delayError` 옵션에 대한 오버로드가 추가되었습니다. |
| `startWith`                         | 인자가 2-9개인 버전이 삭제되었습니다. 대신  `startWithArray`을 쓰세요. |
| N/A                                 | added `startWithArray` to disambiguate   |
| N/A                                 | added `subscribeWith` that returns its input after subscription |
| `switchMap`                         | `prefetch` 인자에 대한 오버로드가 추가되었습니다.         |
| `switchMapDelayError`               | `prefetch` 인자에 대한 오버로드가 추가되었습니다.         |
| `takeLastBuffer`                    | 없어졌습니다.                                  |
| N/A                                 | `test()`가 추가되었습니다. (`TestSubscriber`를 반환하여 이를 구독할 수 있습니다.) 자연스러운 테스트를 위한 오버로드가 추가되었습니다. |
| `timeout(Func0, ...)`               | `timeout(Publisher, ...)`로 서명이 바뀌었습니다. 가능할 경우  `defer(Callable>)`를 써주세요. |
| `toBlocking().y`                    | `toFuture`를 제외하고는 `blockingY()` 오퍼레이터로 인라인됩니다. |
| `toCompletable`                     | **RC3**에서 없어졌습니다. `ignoreElements`를 쓰세요. |
| `toList`                            | **RC3**부터는 `Single`을 반환합니다.              |
| `toMap`                             | **RC3**부터는 `Single`을 반환합니다.              |
| `toMultimap`                        | **RC3**부터는 `Single`을 반환합니다.              |
| N/A                                 | `toFuture`가 추가되었습니다.                     |
| N/A                                 | `toObservable`가 추가되었습니다.                 |
| `toSingle`                          | **RC3**에서 없어졌습니다. `single(T)`를 쓰세요.      |
| `toSortedList`                      | **RC3**부터는 `Single`을 반환합니다.              |
| `withLatestFrom`                    | 5-9 소스 오버로드가 없어졌습니다.                     |
| `zipWith`                           | `prefetch`와  `delayErrors` 옵션에 대한 오버로드가 추가되었습니다. |

#### 달라진 반환 타입

정확히 하나의 값이나 에러를 생성한 오퍼레이터는 2.x에서는 `Single`을 반환합니다. (빈 소스가 허용되면 `Maybe`도 가능합니다).

*(Remark: 이는 RC2와 RC3에서 혼합된 타입의 시퀀스로 프로그래밍하는게 어떤지, 또 거기에 너무 많은 toObservable/toFlowable 변환이 너무 많지 않은지를 보기 위한 "실험적 기능"입니다.)*

| 오퍼레이터                          | 예전 반환 타입     | 새 반환 타입       | 비고                                       |
| ------------------------------ | ------------ | ------------- | ---------------------------------------- |
| `all(Predicate)`               | `Observable` | `Single`      | 모든 요소가 인자와 일치하면 true를 방출합니다.             |
| `any(Predicate)`               | `Observable` | `Single`      | 특정 요소가 인자와 일치하면 true를 방출합니다.             |
| `count()`                      | `Observable` | `Single`      | 시퀀스에 있는 항목의 갯수를 방출합니다.                   |
| `elementAt(int)`               | `Observable` | `Maybe`       | 주어진 인덱스의 항목을 방출하거나 완료합니다.                |
| `elementAt(int, T)`            | `Observable` | `Single`      | 주어진 인덱스의 항목 혹은 미리 지정한 항목을 방출합니다.         |
| `first(T)`                     | `Observable` | `Single`      | 첫 항목을 방출하거나 `NoSuchElementException`를 냅니다. |
| `firstElement()`               | `Observable` | `Maybe`       | 첫 항목을 방출하거나 완료합니다.                       |
| `ignoreElements()`             | `Observable` | `Completable` | 터미널 이벤트를 제외한 모든 걸 무시합니다.                 |
| `isEmpty()`                    | `Observable` | `Single`      | 소스가 비어있을 때 true를 방출합니다.                  |
| `last(T)`                      | `Observable` | `Single`      | 마지막 항목 혹은 미리 지정한 항목을 방출합니다.              |
| `lastElement()`                | `Observable` | `Maybe`       | 맨 마지막 항목을 방출하거나 완료합니다.                   |
| `reduce(BiFunction)`           | `Observable` | `Maybe`       | 줄어든 값을 방출하거나 완료합니다.                      |
| `reduce(Callable, BiFunction)` | `Observable` | `Single`      | 초깃값 혹은 줄어든 값을 방출합니다.                     |
| `reduceWith(U, BiFunction)`    | `Observable` | `Single`      | 초깃값 혹은 줄어든 값을 방출합니다.                     |
| `single(T)`                    | `Observable` | `Single`      | 유일한 항목 혹은 미리 지정한 항목을 방출합니다.              |
| `singleElement()`              | `Observable` | `Maybe`       | 유일한 항목을 방출하거나 완료합니다.                     |
| `toList()`                     | `Observable` | `Single`      | `List`로 항목을 모읍니다.                        |
| `toMap()`                      | `Observable` | `Single`      | `Map`으로 항목을 모읍니다.                        |
| `toMultimap()`                 | `Observable` | `Single`      | `Map`과 콜렉션으로 항목을 모읍니다.                   |
| `toSortedList()`               | `Observable` | `Single`      | `List`로 항목을 모으고 정렬합니다.                   |

### 삭제된 사항

2.0의 최종 API를 최대한 깨끗하게 만들기 위해, 우리는 릴리즈 후보를 거치면서 메소드와 일부 컴포넌트를 사용되지 않도록 만들지 않고 바로 삭제했습니다.

| 삭제된 버전 | 컴포넌트                         | 대안                                  |
| ------ | ---------------------------- | ----------------------------------- |
| RC3    | `Flowable.toCompletable()`   | `Flowable.ignoreElements()`를 쓰세요.   |
| RC3    | `Flowable.toSingle()`        | `Flowable.single(T)`를 쓰세요.          |
| RC3    | `Flowable.toMaybe()`         | `Flowable.singleElement()`를 쓰세요.    |
| RC3    | `Observable.toCompletable()` | `Observable.ignoreElements()`를 쓰세요. |
| RC3    | `Observable.toSingle()`      | `Observable.single(T)`를 쓰세요.        |
| RC3    | `Observable.toMaybe()`       | `Observable.singleElement()`를 쓰세요.  |

## 잡다한 변경사항

### doOnCancel / doOnDispose / unsubscribeOn

1.x에서는 `SafeSubscriber`가 자체적으로 `unsubscribe`를 호출했기 때문에 `doOnUnsubscribe`는 터미널 이벤트에서 항상 실행되었습니다. 이것은 실질적으로 불필요한 일이며, Reactive-Streams 사양에서는 터미널 이벤트가 `Subscriber`에게 도착하면 업스트림 `Subscription`이 취소된 것으로 간주하여야 하므로`cancel()`을 호출하는 것은 아무 작업도 수행하지 않아야한다고 명시합니다.

같은 이유로 `unsubscribeOn`는 일반적인 종료 경로에서 호출되지 않고 체인에서 실제 `cancel`(또는 `dispose`)  호출이 있을 때만 호출됩니다.

따라서 다음 시퀀스는 `doOnCancel`을 호출하지 않을 것입니다.

{% highlight java %}
Flowable.just(1, 2, 3)
  .doOnCancel(() -> System.out.println("Cancelled!"))
  .subscribe(System.out::println);
{% endhighlight %}

그러나 다음 시퀀스는 `take` 오퍼레이터가 `onNext` 이벤트가 전달된 후에 취소되기 때문에 `doOnCancel`이 호출됩니다.

{% highlight java %}
Flowable.just(1, 2, 3)
  .doOnCancel(() -> System.out.println("Cancelled!"))
  .take(2)
  .subscribe(System.out::println);
{% endhighlight %}

만약 일반적인 터미네이션 과정이나 종료 과정에서 모두 정리를 해야할 때는, 대신 `using` 오퍼레이터를 쓰는걸 고려해보세요.



# 후기

주관적인 생각이지만 영어 번역은 확실히 일본어 번역보다 더 어려웠던 것 같습니다. 특히 글의 분량도 많았고, 어떻게 하면 이 표현을 자연스럽게 우리말로 쓸 수 있을까에 대한 고민도 꽤 했지만 그럼에도 많이 부족한 것 같습니다. 이 글을 통해 RxJava 2가 어떤 점들이 바뀌었는지 아는데 도움이 되면 좋겠습니다. 오타나 번역에 대한 지적이라던가 댓글은 언제나 환영합니다. 감사합니다. :D