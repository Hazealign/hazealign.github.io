---
layout: post
title: "GDG Android Korea RxJava 스터디: 1회차"
date: 2016-06-09 10:00:00 +0900
categories: Code
tags: android rxjava development observable
---

## 주제

```
1. Queue로써 Rx 활용
 - gdgand/android-rxjava
 
2. Lambda 동작의 이해
http://www.slideshare.net/jaxlondon2012/lambda-a-peek-under-the-hood-brian-goetz (p.19 ~)

3. 내가 RxJava 를 쓰는 이유
https://speakerdeck.com/jakewharton/android-development-with-kotlin-androidkw-number-001 (p.11)
http://www.slideshare.net/jpaumard/java-8-stream-api-and-rxjava-comparison (p.213 ~)
```

## 1. Queue로 Rx 활용하기

1. 푸쉬 메세지 예제
	- Device를 껐다가 켰을 때 오는 100개 정도의 알람을 해결할 때 사용함.
	- `commandQueue`라는 PublishSubject를 만들고, `onBackPressureBuffer`를 이용함.
	- `PublishSubject`는 크기의 한계가 있기 때문에 `onBackPressureBuffer`를 같이 쓰는게 좋음.
	- 이렇게 RxJava로 Queue를 구현하면 Multi-thread의 동시성 문제, `synchronize` 등등 수많은 작업을 짧게 할 수 있음.
	- PublishSubject를 Queue처럼 활용할 수 있음.
2. RecyclerView의 Adapter에서 Observable 안에서 백그라운드 쓰레드로 처리함으로써 RecyclerView의 Frame 속도를 개선할 수 있음.
	- 에러의 예외처리같은 경우에는 RxRelay의 `PublishRelay`를 쓰면 onError가 호출된 뒤에도 다시 emit을 받을 수 있다.
3. EventBus인 Otto를 RxJava로 옮기는 예제에서 PubSub를 쓰고 있기 때문에 예제를 체크해볼 필요가 있음.
4. CompositeSubscription의 `unsubscribe`와 `clear`의 차이?
	 - 거의 비슷하지만 `unsubscribed`가 true냐 아니냐의 차이.

**참고자료**

 - [https://github.com/ReactiveX/RxJava/blob/master/src/main/java/rx/subscriptions/CompositeSubscription.java](https://www.youtube.com/watch?v=QdmkXL7XikQ)
 - [https://github.com/ReactiveX/RxJava/issues/2959](https://www.youtube.com/watch?v=QdmkXL7XikQ)
 - [https://www.youtube.com/watch?v=QdmkXL7XikQ](https://www.youtube.com/watch?v=QdmkXL7XikQ)
	 - [https://speakerdeck.com/dlew/common-rxjava-mistakes](https://www.youtube.com/watch?v=QdmkXL7XikQ)

## 2. Lambda식이 내부에서 어떻게 동작하는가. & 3. 내가 RxJava를 쓰는 이유
 - 람다식이 동작하는 원리를 알기 위해서는 Java 7과 8의 스펙을 이해해야함.
 - 자바 컴파일러는 람다 표현식을 `invokedynamic`으로 컴파일한다.
 - Java 7에서 `invokedynamic`이라는 바이트코드가 폴리글랏을 지원하기 위해 새로 추가됨
	 - `invokedynamic`의 인자는 Bootstrap Method에 대한 레퍼런스다. 
	 - Bootstrap Method는 `CallSite` 인스턴스를 생성하며, 이 인스턴스는 런타임에 적합한 메소드를 실행하는 역할을 한다.
	 - `CallSite` 인스턴스에는 `MethodHandle`이 연결되어있고, 런타임에서 JVM에 의해 실행된다.
 - Android에서는 Java 8의 람다 표현식이나 Stream API를 쓸 수 없음. 람다 표현식을 쓰기 위한 방법은 바이트코드 레벨에서 백포팅해주는 Retrolambda를 이용할 수 있음.
 - Stream API를 쓰는데에는 RxJava나 LightweightStream, FunctionalJava 등이 있지만 승욱님이 당시에 알아봤을 때는 RxJava가 제일 잘 맞았기 때문에 이것을 쓰게 되었음.
 - 물론 Stream API와 직접 비교를 하면 당연히 RxJava가 한참 느릴 수 밖에 없음.
	 - 특히 ParallelStream이 병렬적으로 처리를 하기 때문에 특히 더 빠르지만, 동시성 문제에 대해서 조심해서 사용해야함.
	 - 이 ParallelStream은 Java 7에 추가된 동시성 처리를 위한 Fork/Join을 이용해서 만들어짐.

**참고자료들**

 - [https://docs.oracle.com/javase/7/docs/api/java/lang/invoke/MethodHandle.html](http://stackoverflow.com/questions/24629247/where-does-official-documentation-say-that-javas-parallel-stream-operations-use)
 - [https://slipp.net/wiki/pages/viewpage.action?pageId=19530380](http://stackoverflow.com/questions/24629247/where-does-official-documentation-say-that-javas-parallel-stream-operations-use)
 - [https://groups.google.com/forum/#!topic/ksug/wrFMOwFugwY](http://stackoverflow.com/questions/24629247/where-does-official-documentation-say-that-javas-parallel-stream-operations-use)
 - [https://docs.oracle.com/javase/tutorial/essential/concurrency/forkjoin.html](http://stackoverflow.com/questions/24629247/where-does-official-documentation-say-that-javas-parallel-stream-operations-use)
 - [http://www.oracle.com/technetwork/articles/java/fork-join-422606.html](http://stackoverflow.com/questions/24629247/where-does-official-documentation-say-that-javas-parallel-stream-operations-use)
 - [https://docs.oracle.com/javase/tutorial/essential/concurrency/forkjoin.html](http://stackoverflow.com/questions/24629247/where-does-official-documentation-say-that-javas-parallel-stream-operations-use)
 - [http://stackoverflow.com/questions/24629247/where-does-official-documentation-say-that-javas-parallel-stream-operations-use](http://stackoverflow.com/questions/24629247/where-does-official-documentation-say-that-javas-parallel-stream-operations-use)

## 후기

이번과 같이 Java의 언어 기능의 동작 원리를 알기 위해서는 언어 표준과 바이트코드까지에 대한 지식이 필요한데 개인적으로는 이렇게 깊게까지 공부해본 적이 없었기 때문에 좀 더 공부가 필요하다는 것을 많이 느꼈습니다. 개인적으로 Java 7에서 추가된 기능들이 그렇게 크지 않다고 생각했는데, 람다식과 병렬 스트림을 위해서 필요한 개념들은 Java 7에 추가되었다는 것을 보고 반성하게 되었습니다. 
