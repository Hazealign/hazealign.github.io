---
layout: post
title: Redux의 개념을 RxJS와 TypeScript로 이해하기 Ver. 2
date: 2017-01-18 12:00:00 +09:00
categories: Code
tags: featured development redux javascript rxjs angular typescript
---

### 글에 앞서,

이 글은 @ovrmrw님의 [글](http://qiita.com/ovrmrw/items/8cca6f40d5f78909a3dc)을 한국어로 번역한 글입니다. 이미 꽤 인기를 얻어서 최신 버전까지 나온 글로, 제가 번역한 것은 2번째 버전입니다. 좋은 글을 번역할 수 있도록 흔쾌히 허락해주신 ovrmrw님께 다시 한번 감사의 말씀을 드립니다. 그리고 번역하다가 헷갈려할 때 도와주신 최종찬 형(@disjukr), 이재호님(@sairion)께도 감사하다는 말씀 드립니다. :D



[Redux Advent Calendar 2016](http://qiita.com/advent-calendar/2016/redux) 15일차입니다. 치키 씨입니다.

## 서론과 반성

이 글은 필자가 Qiita에 투고한 글 중 제일 스톡이 많이 된 글인 [초심자를 위한 Redux의 개념을 RxJS와 TypeScript로 이해하기](http://qiita.com/ovrmrw/items/89c79fae4a2acd8159fc)를 다시 쓴 글입니다. (역주: Qiita에서는 스톡이라는 기능이 있어, 좋아하는 글을 담아두고 볼 수 있도록 제공하고 있습니다.)

지금 다시 되돌아보면, 지난 글에는 몇가지 문제점이 있었습니다.

1. State와 Reducer에 Promise를 넣는건 좋지 못했던 것 같습니다.
2. Action의 dispatch 순서를 무시하고, 비동기 처리가 끝난 순서대로 처리가 흐르는 구조로 되어있었다.

1번에 관해서는 처음에는 문제가 없다고 생각했었지만, 점점 시간이 흘러 그 생각은 젊은 치기였던 것 같다고 생각하게 되었습니다. 2번은 요구사항에 따라선 그것대로 괜찮다고 생각되지만, 그래도 기본적으로 dispatch 순서대로 처리하는 것이 더 올바른 동작이라고 생각하게 되었습니다.

"RxJS로 Redux를 쓰자"라는 테마는 이번에 글을 다시 쓰면서 이제서야 본질에 접근할 수 있었다고 생각합니다.

## 여기서부터 본편

GitHub 리포지터리는 여기에 있습니다. [ovrmrw/understanding-redux-with-rxjs-2](https://github.com/ovrmrw/understanding-redux-with-rxjs-2)

`git clone`한 뒤, `npm install`해서 `npm start`를 통해 실행해볼 수 있습니다.

(주의사항: React에 관한 이야기는 일절 나오지 않습니다.)

## Redux는?

[Redux 공식 홈페이지](http://redux.js.org/)

전체 애플리케이션의 상태(State)를 하나의 JSON 트리 구조로 가지게 되어, Action이 발생할 때마다 트리를 전체적으로 업데이트해서 전달한다는 개념. 필자는 처음에 Flux나 Redux에 대해서 잘 몰랐지만, 다양한 것들을 참고하면서 직접 쓰면서 겨우 이해할 수 있었습니다.

Middleware라는 개념은 잘 몰랐었고, 지금도 잘 모릅니다. 로거같은 편리한 것도 있습니다만, 원래 Redux를 그대로 사용해본 적이 없습니다. 치명적인 문제로 Redux는 Reducer의 안에서 비동기 처리를 할 수 없기 때문에, 그것을 처리하기 위한 미들웨어 전쟁이 일어나고 있는 것이 있습니다.

## Redux를 이해하기

"그러나 Angular 파인 우리들은 원래부터 RxJS가 있었다! 그래서 RxJS를 풀로 써서 Redux같은걸 만들어서 쓰자!"같은 말도 나왔습니다. 원래 글은 여기에 있습니다. ["Tackling State" by Victor Savkin](https://vsavkin.com/managing-state-in-angular-2-applications-caf78d123d02#.7zwj38sy1) (Victor Savkin은 Angular 팀의 핵심 멤버입니다. 그의 블로그는 구독할만한 가치가 있다고 생각합니다.)

에서, 당시 RxJS에 대한 지식이 얕았었다. (JS에 대한 이해도 부족했었다.) 그래서 나는 이것을 이해하는데 매우 오랜 시간이 걸렸습니다. Savkin류 Redux를 나름대로 몇번이나 고쳐쓰는 것을 반복해서, 마침내 지금까지 오게 되었습니다. 사실은 하나의 간단한 짧은 코드로 모든 것을 설명할 수 있다는 것을 알 수 있었습니다.

[![687474703a2f2f692e696d6775722e636f6d2f4149696d5138432e6a7067.jpeg](https://qiita-image-store.s3.amazonaws.com/0/74793/6c582eff-0424-3f65-c421-8dcbc931db4d.jpeg)](https://qiita-image-store.s3.amazonaws.com/0/74793/6c582eff-0424-3f65-c421-8dcbc931db4d.jpeg)

{ % highlight typescript % }
import 'core-js';
import 'zone.js/dist/zone-node';
import * as lodash from 'lodash';
import { Observable, Subject, BehaviorSubject } from 'rxjs';
declare const Zone: any;


///////////////////////////////// Action
class IncrementAction {
  constructor(public num: number) { }
}

class OtherAction {
  constructor() { }
}

type Action = IncrementAction | OtherAction;


///////////////////////////////// State
interface IncrementState {
  counter: number;
}

interface OtherState {
  foo: string;
  bar: number;
}

interface AppState {
  increment: IncrementState;
  other?: OtherState;
}


const initialState: AppState = {
  increment: {
    counter: 0
  }
};


///////////////////////////////// Redux
Zone.current.fork({ name: 'myZone' }).runGuarded(() => {

  console.log('zone name:', Zone.current.name); /* OUTPUT> zone name: myZone */

  const dispatcher$ = new Subject<Action | Promise<Action> | Observable<Action>>(); // Dispatcher
  const provider$ = new BehaviorSubject<AppState>(initialState); // Provider


  const dispatcherQueue$ = // Queue
    dispatcher$
      .concatMap(action => { // async actions are resolved here.
        if (action instanceof Promise || action instanceof Observable) {
          return Observable.from(action);
        } else {
          return Observable.of(action);
        }
      })
      .share();


  Observable // ReducerContainer
    .zip(...[
      dispatcherQueue$.scan((state, action) => { // Reducer
        if (action instanceof IncrementAction) {
          return { counter: state.counter + action.num };
        } else {
          return state;
        }
      }, initialState.increment),

      (increment): AppState => { // projection
        return Object.assign<{}, AppState, {}>({}, initialState, { increment }); // always create new state object!
      }
    ])
    .subscribe(newState => {
      provider$.next(newState);
    });


  provider$
    .map(appState => appState.increment)
    .distinctUntilChanged((oldValue, newValue) => lodash.isEqual(oldValue, newValue)) // restrict same values to pass through.
    .subscribe(state => {
      console.log('counter:', state.counter); /* (First time) OUTPUT> counter: 0 */
    });


  /* 
    OUTPUT: 0 -> 1 -> 2 -> 4 -> 3 
    outputs are not determined by async resolution order but by action dispatched order.
  */
  dispatcher$.next(promiseAction(new IncrementAction(1), 100));  /* OUTPUT> counter: 1 */
  dispatcher$.next(promiseAction(new IncrementAction(1), 50));  /* OUTPUT> counter: 2 */
  dispatcher$.next(observableAction(new IncrementAction(0), 100));  /* OUTPUT> (restricted) */
  dispatcher$.next(observableAction(new IncrementAction(2), 50));  /* OUTPUT> counter: 4 */
  dispatcher$.next(new IncrementAction(-1)); /* OUTPUT> counter: 3 */
});



///////////////////////////////// Helper
function promiseAction(action: Action, timeout: number): Promise<Action> {
  return new Promise<Action>(resolve => {
    setTimeout(() => resolve(action), timeout);
  });
}

function observableAction(action: Action, timeout: number): Observable<Action> {
  return Observable.of(action).delay(timeout);
}
{ % endhighlight % }

어떤가요, 초간단하죠?

덧붙여서 이번 코드는 [zone.js](https://github.com/angular/zone.js/)을 사용할 필요는 없습니다만, 추후 Angular에서 돌아갈 코드는 가능한 Node.js 환경에서도 Zone을 이용하여 쓰는 것이 좋습니다. 그렇지 않으면 Node.js 환경에서 동작하는 코드가 Angular에서 동작하지 않는다던가 하는 일이 발생할 수 있기 때문입니다. (전 그저 Angular를 좋아할 뿐입니다.)

## 요점 1. Subject

{ % highlight typescript % }
  dispatcher$.next(promiseAction(new IncrementAction(1), 100));
{ % endhighlight % }

이것이 Action의 시작점입니다. 덧붙여서 `dispatcher$`는 `Subject`의 인스턴스입니다. 이 다음에 스트림이 어디로 흐를까요? 정답은 `dispatcherQueue$`입니다.

## 요점 2. concatMap

{ % highlight typescript % }
  const dispatcherQueue$ = // Queue
    dispatcher$
      .concatMap(action => { // async actions are resolved here.
        if (action instanceof Promise || action instanceof Observable) {
          return Observable.from(action);
        } else {
          return Observable.of(action);
        }
      })
      .share();
{ % endhighlight % }

`dispatcher$`로 부터 흘러들어온 Action을 `concatMap` 오퍼레이터로 받고 있습니다. 무엇을 하고 있냐면…

- Promise 혹은 Observable, 즉 비동기라면 `Obervable.from()`로 비동기를 해결해서 돌려줍니다.
- 그 외, 동기식이라면 `Observable.of()`로 단순히 Observable로 변환해줍니다.

이것을 통해 `Observable | Observable>`이었던 Action의 타입은 `Observable`로 통일됩니다.

게다가 `concatMap`의 효과에 의해 Action의 dispatch 순서를 준수합니다. 멋지네요. 이 Reducer의 앞에서 비동기를 해결하자는 어프로치는 redux-observable에서도 통하는 부분이 있습니다.

[![img](http://reactivex.io/documentation/operators/images/concatMap.png)](http://reactivex.io/documentation/operators/images/concatMap.png)

## 요점 3. BehaviorSubject

{ % highlight typescript % }
const provider$ = new BehaviorSubject<AppState>(initialState);
{ % endhighlight % }

여기에서는 `Subject`로서가 아니라 `BehaviorSubject`인게 의미가 있습니다. 만약 이를 Subject로 바꾼다면 처음 "counter: 0"이 출력되지 않습니다. 초기 값이 바로 전달되는 모습은 아래 마블 다이어그램에서 보면 알기 쉬울 것 같습니다.

[Subject의 문서](http://reactivex.io/documentation/subject.html)

[![S.BehaviorSubject.png](https://qiita-image-store.s3.amazonaws.com/0/74793/ddbaa374-6810-129b-5ba1-d1162bd6902d.png)](https://qiita-image-store.s3.amazonaws.com/0/74793/ddbaa374-6810-129b-5ba1-d1162bd6902d.png)

## 요점 4. scan

{ % highlight typescript % }
      dispatcherQueue$.scan((state, action) => { // Reducer
        if (action instanceof IncrementAction) {
          return { counter: state.counter + action.num };
        } else {
          return state;
        }
      }, initialState.increment)
{ % endhighlight % }

이 부분이 바로 Reducer입니다. `scan` 오퍼레이터는 Store(Reducer)를 구축하게 됩니다. 이것은 시간과 만나는 reduce라고 이해하면 그걸로 충분할거라 생각합니다. 이 `scan`과 아래의 `zip`을 제대로 이해할 수 있는가가 이 글을 이해했는가를 결정합니다.

[scan의 마블 다이어그램](http://rxmarbles.com/#scan)

`dispatcher$.scan()` 대신, `dispatcherQueue$.scan()`인 것이 중요합니다.

## 요점 5. zip, projection

{ % highlight typescript % }
      (increment): AppState => { // projection
        return Object.assign<{}, AppState, {}>({}, initialState, { increment });
      }
{ % endhighlight % }

`zip` 오퍼레이터의 마지막 인자로 projection이라고 불리는 함수를 넣어 반환 값을 갖추고 있습니다. 참고로 `zip` 안이 여러 개 있을 때에는 다음과 같이 씁니다.

{ % highlight typescript % }
    .zip<AppState>(...[
      dispatcher$.scan(/* 생략 */), // state1
      dispatcher$.scan(/* 생략 */), // state2
      dispatcher$.scan(/* 생략 */), // state3

      (state1, state2, state3): AppState => { // projection
        return Object.assign<{}, AppState, {}>({}, initialState, { state1, state2, state3 });
      }
    ])
{ % endhighlight % }

[zip의 마블 다이어그램](http://rxmarbles.com/#zip)
`zip`과 비슷한 `combineLatest`라는 오퍼레이터가 있습니다만 `zip`은 내포하는 모든 Observable의 next를 기다리는 반면, `combineLatest`는 한 Observable이 next할 때마다 각각의 Observable의 최신 값을 넘겨줍니다.

이와 같은 이유로, Redux의 개념에는 `zip`이 적합하다 할 수 있습니다.
[combineLatest의 마블 다이어그램](http://rxmarbles.com/#combineLatest)

## 요점 6. distinctUntilChanged

{ % highlight typescript % }
    .distinctUntilChanged((oldValue, newValue) => lodash.isEqual(oldValue, newValue))
{ % endhighlight % }

`distinctUntilChanged`오퍼레이터는 통과하는 스트림이 같은 값일 경우에는 없애주는 역할을 합니다. 하지만 이번 코드는 위의 Projection의 쪽에서, 

{ % highlight typescript % }
return Object.assign<{}, AppState, {}>({}, initialState, { increment });
{ % endhighlight % }

이렇게 하고 있기 때문에, 단순히 `.distinctUntilChanged()`라고 써버리면 흘러온 데이터가 `{counter: 2}`→`{counter: 2}`와 같이 같은 값이 계속 오더라도 모두 통과해버립니다. 이것은 객체의 내용을 보지 않기 때문입니다.

객체의 내용을 확인하기 위해 소위 deepEqual 비교를 해야하기 때문에, comparer라고 불리는 함수를 아래와 같이 작성합니다.

{ % highlight typescript % }
(oldValue, newValue) => lodash.isEqual(oldValue, newValue)
{ % endhighlight % }

[distinctUntilChanged의 문서](http://reactivex.io/documentation/operators/distinct.html)
[lodash.isEqual의 문서](https://lodash.com/docs/#isEqual)

## Angular에서 쓰기 위해선

Dispatcher를 DI 컨테이너에 넣어 Component에 주입하면 Component부터 Action을 날릴 수 있습니다. 또한 Provider 스트림의 마지막 부분을 어떻게 해서 Component에 주입하면 Component에서 갱신된 State를 얻을 수 있습니다.

덧붙여서 [Firebase-as-a-Store "RxJS로 만드는 Firebase 백엔드의 Redux"](http://qiita.com/ovrmrw/items/27d06475f405fd4ca9b4)에서 소개하고 있는 Angular 애플리케이션은 이 개념을 고스란히 이용해 구축했습니다.

## 정리하기

요점은 여러 가지가 있지만 가장 중요한 것은 Reducer를 구성하는 `scan`, `zip` 오퍼레이터 부분입니다. Reducer를 늘리고 싶다면 `zip` 오퍼레이터에 점점 `dispatcherQueue$.scan`을 추가해가면 됩니다. 해야할 일은 그것 뿐입니다.