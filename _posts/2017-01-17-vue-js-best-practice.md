---
layout: post
title: Vue.js를 쓸 때의 모범 사례에 대해서 생각해보다.
date: 2017-01-17 12:00:00 +09:00
categories: Code
tags: featured development vue vuejs jsx javascript 
---

### 글에 앞서,

이 글은 Qiita에 올라온 @EdwardKenFox님의 [글](http://qiita.com/edwardkenfox/items/6f4aa591485d2a270841)을 한국어로 번역한 글입니다. 개인적으로 Vue.js에 관심이 있어서 찾아보면서 좋은 글을 발견해서 번역해봤습니다. 혹시 번역에 이상하거나 모르는 부분이 있다면 댓글로 남겨주시면 감사하겠습니다. 흔쾌히 번역을 허락해주신 EdwardKenFox님께도 감사하다는 말씀 드립니다.


Vue.js는 공식 문서가 매우 충실하고, 또 포럼에서의 토론이나 의사 소통 또한 매우 활발합니다. 개발 중에 무언가 문제가 발생했을 때에는 문서 혹은 포럼에 올라온 정보를 참고하면 많은 문제들을 해결할 수 있다고 해도 무방합니다. 하지만 실제 애플리케이션을 개발할 때에는 그러한 정보만으로 해결이 어려운 구체적인 문제들이나, 원래 어떻게 개발해야 좋을지 모르는 일이 생기는 경우도 많이 있습니다.

필자 자신이 Vue.js를 이용해서 프론트엔드 개발을 해온 경험과 더불어, Vue.js의 공식 문서와 샘플 프로젝트, 그리고 Vue.js의 플러그인 등의 소스를 읽고 축적한 노하우들을 문서로 정리했습니다.

"모범 사례"라고 이름을 붙이고는 있지만, 필자의 취향과 개발 경험에 의존하는 부분이 크겠죠. 본 자료를 보다 의미있게 만들기 위해 Vue.js를 이용해서 개발을 할 때의 노하우와 사례를 가지고 계신 분들은 꼭 댓글이나 편집 요청(역주: Qiita에는 편집 요청을 통해 다른 사용자가 글에 수정 요청을 할 수 있습니다.)을 통해 가르쳐주세요!

## 버전

당연한 이야기이지만, 새로 개발을 시작하는 프로젝트라면 Vue.js의 최신 버전을 쓴다고 해서 문제가 될 것이 없습니다. 2016년 12월 18일 기준으로는 [v2.1.6](https://github.com/vuejs/vue/tree/v2.1.6)이 최신 버전입니다.

또한 1.x 버전을 이용하고 있는 프로젝트는 2.x로 업그레이드하는 것을 추천합니다. 완전히 새로워진 부분도 있기 때문에 1.x에서 2.x로의 마이그레이션이 쉽지 않을 수도 있지만, 그래도 많은 혜택을 누릴 수 있을 것입니다. 1.x에서 2.x로 마이그레이션하는데 사용할 수 있는 도구가 있고, deprecated된 API에 대한 안내와 가이드도 잘 쓰여 있기 때문에 참고하시면 도움이 될 것입니다.

**Reference**

- [vue-migration-helper](https://github.com/vuejs/vue-migration-helper)
- [Migration from Vue 1.x](https://vuejs.org/v2/guide/migration.html)

## 패키지 관리 도구

Vue 플러그인의 리포지터리를 다양하게 찾아보면 보통은 npm 패키지의 관리를 위해 npm을 이용하는 곳이 대부분이었습니다. 개발이 활발한 일부 저장소의 경우는 yarn을 이용하는 곳도 있었습니다만 그 수는 많지 않았던 것 같습니다.

하지만 npm에 비해 yarn은 의존하는 라이브러리가 많을수록 설치가 빠르다는 벤치마크 결과도 나와 있어 새 프로젝트에서 yarn을 쓰지 않을 이유는 없을지도 모릅니다. CI 등으로 yarn을 사용할 때는 캐시 설정 등을 조심해서 사용할 필요가 있습니다.

**Reference**

- [yarn vs npm@2 vs npm@3](https://speakerdeck.com/pine613/yarn-vs-npm-at-2-vs-npm-at-3)

## 빌드 도구

Vue.js 공식에서 제공하고 있는 vuejs-templates에는 webpack과 browserify를 위한 샘플 설정 파일과 구현이 있습니다. 각 저장소의 스타 수를 보면 webpack쪽이 압도적으로 인기인 것 같네요. Vue.js 라이브러리 등을 봐도 webpack을 사용하고 있는 곳이 대부분이며, 어셋 등을 쉽게 관리할 수 있는 기능이 있는 webpack을 사용하는 것을 권장합니다.

## 기법

v-on과 v-bind를 이용할 때는 역시 간결한 단축법을 선호하는 것 같습니다. 또한 여러 사람이 개발하는 프로젝트라면 ESLint과 `.editorconfig ` 등을 이용하여 문법과 구문을 통일하는게 일반적입니다.

## Props의 타입 체크

`props`를 통해 들어오는 값의 타입 체크는 가능한 사용하는 것이 좋겠죠. 예를 들어 양의 정수를 기대하는 `props`일 때에는 Number 형인지 검사하는 것과 함께 음수가 아닌지 validate해준다면 알아채기 어려운 버그를 줄이는데 큰 도움이 됩니다.

{% highlight javascript %}
// not so good
Vue.component('child', {
  props: ['age']
}) 

// good
Vue.component('child', {
  props: {
    age: {
      type: Number
    }
  }
}) 

// better
Vue.component('child', {
  props: {
    age: {
      type: Number,
      required: true,
      validator: function(value) {
        return value >= 0;
      }
    }
  }
}) 
{% endhighlight %}

`props`의 타입 체크에는 여러가지 형태를 지정하거나 `null`로 지정하여 모든 형태를 허용할 수 있습니다만, 이처럼 `null`로 지정하는 것은 지양하는 것을 추천합니다. 아무래도 `null`을 지정하는 경우에는 하나의 형식의 값을 전달할 수 있도록 컴포넌트나 `props`로 넘기는 방식으로 데이터의 구조를 다시 검토해보는 것이 좋을 것 같습니다. 

**Reference**

- [Prop Validation](https://vuejs.org/v2/guide/components.html#Prop-Validation)

## 라이프사이클 훅의 활용

Vue.js에는 편리한 API가 많이 준비되어 있습니다만, 이벤트 계열의 메소드나 세세한 컴포넌트 옵션을 구사하기 전에 구현하려고 하는 처리나 행위가 라이프사이클 훅을 잘 활용해서 돌아가는지 점검해볼 필요가 있습니다. 필자의 경험으로는 컴포넌트가 생각했던대로 동작하지 않을 경우 라이프사이클 훅의 사용이 잘못됬었던 경우가 많았습니다. 그럴 경우 자칫 `watch`나 `$emit`을 필요 이상으로 복잡하게 남용하고 있었던 것입니다. 라이프사이클 훅을 잘 맞춰야 심플하고 자연스럽게 동작합니다.

컴포넌트가 단독으로 존재하고 있는 등의 미니멀한 상황에서는 `created`나 `mounted` 같은 라이프사이클을 이용해도 그다지 큰 차이는 없을지도 모릅니다. 하지만 컴포넌트들이 `props` 등을 통해 서로 맞물려서 동작하는 경우는 부모 컴포넌트의 `created`와 자식 컴포넌트의 `mounted` 등의 타이밍 차이를 잘 이해하고 컴포넌트를 작성할 필요가 있습니다.



{% highlight javascript %}
new Vue({
  mounted: function() {
    console.log("Hello from parent");
  }
})

// => "Hello from parent"
{% endhighlight %}

{% highlight javascript %}
Vue.component('child', {
  mounted: function() {
    console.log("Hello from child");
  }
})

new Vue({
  mounted: function() {
    console.log("Hello from parent");
  }
})

// => "Hello from child"
// => "Hello from parent"
{% endhighlight %}

{% highlight javascript %}
Vue.component('child', {
  mounted: function() {
    console.log("Hello from child");
  }
})

new Vue({
  created: function() {
    console.log("Hello from parent");
  }
})

// => "Hello from parent"
// => "Hello from child"
{% endhighlight %}

## v-for로 표시된 컴포넌트의 제거

`v-for`로 렌더링된 아이템의 리스트 중에서 사용자의 조작에 의해 특정 컴포넌트를 제거하는 일은 자주 있다고 생각합니다. 이를 구현하는 방법은 다양할 것이라 생각하지만, 대부분 아래의 두가지 방법인 것 같습니다.

1. 삭제 대상의 컴포넌트(하위 컴포넌트)가 자신의 삭제를 부모 컴포넌트에게 이양하는 패턴 (삭제를 이벤트로 해서 `$emit`하고 실제 삭제 처리는 부모 컴포넌트가 하거나, store에 커밋한다.)
2. 부모 컴포넌트의 함수로 삭제 처리를 구현하고 삭제 함수를 자식 컴포넌트에 `props`로 전달합니다. 실제로 삭제할 때 자식 컴포넌트가 받고 있는 함수를 실행해서 컴포넌트 자신을 제거합니다.

필자 개인적으로는 어떤 방법이 다른 쪽에 비해 특히 우수하다고는 생각하지 않습니다만, UI나 컴포넌트의 분할 단위 관점에서 처리 흐름이 보다 자연스러운 쪽을 선택하는 것이 좋다고 생각합니다. 또한 자식 컴포넌트의 제거 이외에 추가 처리가 이것저것 부수적으로 있을 때에는 두 번째 방법이 더 다루기 쉬울지도 모릅니다.

{% highlight javascript %}
// 패턴 1
Vue.component('child', {
  methods: {
    removeItem: function() {
      this.$parent.$emit('removeItem', this.index);
    }
  }
})
{% endhighlight %}

{% highlight javascript %}
// 패턴 2
Vue.component('child', {
  props: {
    removeItem: {
      type: Function
    }
  }
})
{% endhighlight %}

## 외부 라이브러리의 컴포넌트화

서드 파티 라이브러리, 특히 UI와 관련한 라이브러리의 경우는 Vue 인스턴스 안에서 직접 라이브러리를 사용하는 것이 아니라 Vue의 컴포넌트로 감싸는 것을 고려해보세요. 다른 컴포넌트에서도 Vue의 API를 통해 동작할 수 있게끔 서드 파티 라이브러리의 API에 관심을 기울일 필요가 있습니다.

또 범용적으로 쓰고 싶은 UI의 효과(애니메이션이나 전환 효과같은...) 등은 컴포넌트와 디렉티브를 모두 준비해야한다고 생각합니다. 이렇게 하면 이 효과를 이용하는 다른 컴포넌트의 사정에 맞춰 컴포넌트로 이용하거나, 디렉티브를 통해 이용할지 선택할 수가 있습니다.

**Reference**

- [Wrapper Component](https://vuejs.org/v2/examples/select2.html)
- [vue-touch-ripple](https://github.com/surmon-china/vue-touch-ripple)

## 비동기 통신 라이브러리

얼마 전 [vue-resource](https://github.com/pagekit/vue-resource)가 Vue.js의 공식 비동기 통신 라이브러리였지만, 현재 Vue.js가 공식으로 제공하는 비동기 통신 라이브러리는 없습니다. 원래 Vue.js는 외부 라이브러리를 통합하기 쉽도록 되어있어 펴오 사용하던 익숙한 비동기 통신 라이브러리를 사용하는 것이 좋습니다.

공식에서 벗어나긴 했지만, vue-resource를 이용하고 있는 프로젝트도 많은 것 같습니다. Javascript 전체의 상황을 보면 [axios](https://github.com/mzabriskie/axios)나 [request](https://github.com/request/request) 등이 인기인 것 같습니다. 또한 브라우저의 fetch API를 이용하는 것도 괜찮겠죠. (Safari에서는 아직 네이티브로 구현되어있지 않기 때문에 [polyfill](https://github.com/github/fetch)의 사용이 필요합니다.)

**Reference**

- [Retiring vue-resource](https://medium.com/the-vue-point/retiring-vue-resource-871a82880af4#.phooxp2li) 

## Flux 아키텍쳐의 도입

작년 경부터 Flux 아키텍쳐가 프론트엔드에 새로운 바람을 가져다주고, Vue.js 세계에도 [Vuex](https://github.com/vuejs/vuex)라고 하는 Flux-like한 라이브러리가 공식적으로 제공되고 있습니다. Vuex 자체는 매우 잘 만들어진 라이브러리지만, 애플리케이션의 규모나 복잡도와 잘 부합하는지를 검토해봐야한다고 필자는 생각합니다.

필자 개인적인 감상으로는 중소 규모의 애플리케이션이라면 Vuex를 도입하는 것보다 전에 Vue.js 공식 문서에 적혀있었던 [store 패턴을 도입](https://vuejs.org/v2/guide/state-management.html)해서 상태를 관리하는 것이 더 낫다고 생각합니다. Vuex는 상태 관리와 업데이트에 질서를 가져다주지만, 도중에 도입해버리면 오히려 일관성을 잃거나 불필요한 오버 엔지니어링을 낳을 우려도 있습니다.

[Vue.js 대림절 달력 2016](http://qiita.com/advent-calendar/2016/vue)에도 있듯 [@nekobato](http://qiita.com/nekobato)님의 ["구조의 복잡성와 Vuex 헤쳐보기"](http://qiita.com/nekobato/items/44a7027504a2c65ce664)가 매우 도움이 되기 때문에 흥미가 있는 분들은 그쪽을 참고하시면 도움이 될 것입니다.

## 싱글 파일 컴포넌트

빌드 환경 및 프로젝트 개발 환경에 크게 의존하고 있지만, 싱글 파일 컴포넌트(.vue 파일)을 이용할 수 있는 경우는 적극적으로 활용하는 것이 좋습니다. 컴포넌트는 사용자 인터페이스의 '외형'과 '행동'을 바탕으로 분할한 부품의 단위이며 템플릿(HTML), 외관(CSS), 그리고 동작(Javascript)를 하나의 파일로 끝내는데에는 의미가 있다고 생각합니다. 프론트엔드 개발자와 디자이너가 협동하는 경우에도 싱글 파일 컴포넌트는 통일적인 작업 환경을 만들어주기 때문에, 효율적으로 협어하는데 도움이 될 것으로 기대하고 있습니다.

## 컴포넌트의 재활용

"싱글 파일 컴포넌트"에서도 쓴 것처럼 컴포넌트는 극단적으로 말하면 UI를 분할한 부품이며, UI의 부품은 그것이 속한 페이지의 문맥화에 있습니다. 비슷하게 보이는 UI도 실은 행동이 다르거나 하는 엣지 케이스를 가지는 경우는 적지 않습니다.

이러한 "보기처럼 보이고 실제로는 다른" 부품을 공통의 컴포넌트로 구현해버리면 인수나 `props`에 의한 제어 뿐만 아니라 컴포넌트의 조건 분기가 증가할 수 밖에 없습니다. 이것은 일반적인 컴포넌트를 이용할 때도 큰 부담을 주기도 하며, 버그의 온상이 될 수도 있습니다.

이러한 상황은 UI 디자인을 검토하는 좋은 타이밍에 포착할 수도 있지만, 어쨋든 무리한 공통화와 범용화는 좋은 결과를 가져오지 않는다는 것을 강조하고 싶습니다. 다른 컴포넌트에서 공통 부분을 찾아서 공통화하는 것보다, 한번 공통화된 것을 분리하는 것이 더 어렵습니다. 브라우저의 성능도 나날이 향상하고 대부분의 클라이언트는 빠른 네트워크에서 웹 애플리케이션을 사용합니다. 약간 파일 크기가 커진다고 해도, 무리한 일반화는 삼가하고 코드 베이스를 취급하기 쉬운 형태로 유지하는 것이 더 이점이 크지 않을까요? 

**Reference**

- [Authoring Reusable Components](https://vuejs.org/v2/guide/components.html#Authoring-Reusable-Components)



## 테스트

Vue.js 대림절 달력 2016에서도 일부 테스트와 관련된 글이 올라왔습니다만, 프론트엔드 개발이 계속 복잡해지고 있는 요즘 Vue.js를 이용한 컴포넌트 유닛 테스트를 작성할 필요성은 점점 높아지고 있다고 생각합니다.

그 컴포넌트의 구현을 본 것만으로 컴포넌트의 움직임이나 처리를 모두 이해할 수 있는 컴포넌트라면 일부러 테스트를 할 필요는 없겠죠. 하지만 컴포넌트 간에 `props`가 전달되고, 그것을 바탕으로 컴포넌트의 동작이 바뀌는 경우에는 해당 컴포넌트의 동작이 명시된 테스트 코드가 있으면 안심입니다. 또한 필자 자신은 컴포넌트에서 비동기 통신을 진행하고 응답 내용에 따라 Vue 인스턴스에 값을 설정하는 것 같은 행동을 하는 컴포넌트가 있을 때도 유닛 테스트를 작성하도록 하고 있습니다. 이렇게 테스트를 작성하는 코스트와 테스트를 통해 얻는 안정성(이익)을 헤아리는 것은 어렵지만, 역시 테스트가 있으면 리팩토링을 할 때 안정적으로 진행할 수 있습니다.

**Reference**

- [Unit Testing](https://vuejs.org/v2/guide/unit-testing.html)
- [Vue.js Vue 컴포넌트의 유닛 테스트를 작성해보자](http://qiita.com/potato4d/items/8215941b84c11b845886)
- [axios을 이용한 Vue component의 UnitTest](http://qiita.com/hypermkt/items/e9f34a89221c50de2094)



## 정리하며

Vue.js에 한정하지 않고 어떤 프레임워크도 프레임워크의 특성과 습관을 이해하고 활용하는 것이 중요하다는 것은 의심할 여지가 없습니다. 또한 개발된 애플리케이션도 다양하고, 개발자는 요구사항에 부합하는 설계를 하고 적당한 라이브러리를 쓰는 것이 필요합니다. 이 문서가 Vue.js를 이용하여 프론트엔드 개발을 하고 있는 사람과 앞으로 프론트엔드 개발을 하려는 사람에게 도움이 된다면 기쁠 것 같습니다 