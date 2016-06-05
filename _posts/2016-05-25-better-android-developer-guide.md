---
layout: post
title: "[번역] 중급 이상의 Android 개발자가 Android다운 개발을 하려면 봐야할 URL 목록들"
date: 2016-05-25 02:30:00 +0900
categories: Code
tags: android lifecycle development
---


이 글은 [@yuya_presto](http://twitter.com/yuya_presto)님이 쓰신 [글](http://qiita.com/yuya_presto/items/ab2162078e5d5076c718)을 한국어로 번역한 글입니다. 일부 오역이나 의역이 있을 수 있으며 이 부분에 대해서 양해를 부탁드리며, 좋은 글을 한국어로도 번역할 수 있게 해주신 yuya_presto님께 감사하다는 말씀 드립니다.

사실 글에서는 *중급 이상의*라는 말이 들어가지만, 안드로이드 애플리케이션을 개발하는 개발자라면 꼭 알아둬야할 개념들에 대해서 이야기하는 글이라고 생각합니다.  

****

Java에 대한 이야기는 여러 이야기가 있다고 생각합니다만, Android 개발을 잘 하기 위해서 어떤 것들을 해야 좋을지에 대한 이야기를 해보고자 합니다. 개발 입문을 위한 가이드로는 이미 [좋은 가이드](https://github.com/mixi-inc/AndroidTraining)(일본어)가 있기 때문에 여기서는 더욱 실전적인 내용에 포커스를 맞추고자 합니다.

## 안드로이드 다운 디자인과 개발

### Material Design의 가이드라인

Google이 생각한 최고(?)의 디자인 가이드라인, 그것이 머티리얼 디자인입니다.  
[https://www.google.com/design/spec/material-design/introduction.html](https://www.google.com/design/spec/material-design/introduction.html)

사용해야할 UI 컴포넌트, ListView 등의 레이아웃, 다이얼로그를 띄울 타이밍과 표시할 내용, 화면 전환 시의 애니메이션과 사용 방법 등에 대한 설명이 다양하게 적혀있습니다. 이 내용에 따라 개발하면 상당히 현대적인 Android 앱으로 보이게 됩니다. 사용하려고 마음 먹은 UI 컴포넌트에 대해 조사하는 것만으로도 꽤 큰 효과를 발휘합니다.

![]({{ site.url }}/assets/images/20160525/1.png)

※ 여담입니다만, iOS를 하는 사람들에게는 iOS Human Interface Guidelines가 필수 요소라고 생각합니다.

### 생명 주기

안드로이드 애플리케이션을 개발하는 것은 Java 언어를 마스터하는 것보다도 생명 주기를 마스터해야하는 일이라는 말을 스터디 등에서 나오고 있습니다. 안드로이드 개발이라고 하면 그 생명 주기를 제대로 생각하고 개발하는 것이 중요합니다.

[공식 문서의 입문편](http://developer.android.com/intl/ja/training/basics/activity-lifecycle/index.html)에서는 재개, 일시 정지, 정지 등의 3가지 상태밖에 나오지 않지만 실제로는 엄청나게 큰 생명 주기 메소드의 호출도 있는 것입니다. (특히 Fragment가 얽혀있는 경우 더 복잡해지겠죠.)

그에 대한 정리가 다음 [Repository](https://github.com/xxv/android-lifecycle)에 올라와있습니다. (CC-BY-SA 4.0)

![]({{ site.url }}/assets/images/20160525/2.png)

※ 여담입니다만, Android N에서 멀티윈도우가 지원되면서 onPause()와 onStop()에 대한 개념이 약간 미묘하게 복잡하게 변할 수도 있기 때문에 이 부분은 주의할 필요가 있다고 생각합니다.

### 백 스택과 태스크

`startActivity()`한 후 백 버튼의 동작을 제어하는 것이 백 스택과 태스크입니다. 백 버튼 뿐만이 아니라 작업 스위처(멀티태스킹 화면)에 표시해야할 내용(예를 들면 외부 메일 앱을 실행했을 때, 작업 스위처에 메일 응용 프로그램을 표시할지 여부 등…)도 주의 깊게 생각할 필요가 있습니다.

	Android 개발자라면 누구나 백 스택과 태스크에 대해서 설명할 수 있고, AndroidManifest.xml에 나오는 launchMode의 차이점에 대해서 설명할 수 있겠지요?

라는 말을 하는 것은 정작 [공식 문서](http://developer.android.com/intl/ja/guide/components/tasks-and-back-stack.html)뿐이었고, 실제 동작의 차이를 몰라서 괴로워합니다. 저는 다음 사이트를 참고해서 마침내 어떻게 돌아가는지 이해할 수 있게 되었습니다.

 - [그림으로 이해하는 액티비티 스택 (Qoncept TechBlog)](http://techblog.qoncept.jp/?p=102) (일본어)
 - [Y.A.M의 잡동사니 메모장: Android launchMode의 차이](http://y-anz-m.blogspot.jp/2011/02/androidlauchmode.html) (일본어)

아래 그림은 "그림으로 이해하는 액티비티 스택"에서 인용한 것입니다. 그림이 매우 알기 쉬웠습니다.

![]({{ site.url }}/assets/images/20160525/3.png)

※ 사실은 "taskAffinity"에 대해서도 알아야한다고 생각하지만, 저는 아직 이 부분에 대해서 확실하게 이해하지 못하고 있습니다.

### Up 내비게이션

안드로이드 개발자라면 백 버튼과 왼쪽 상단의 "Up 버튼"이 어떻게 다른지 설명할 수 있죠? Up 버튼은 전에 표시된 화면으로 되돌아가는 것이 아니라 "상위 개념"으로 이동해야만 합니다. Up 내비게이션은 간과하기 쉬운 구조이므로 화면 전환이 많은 프로그램에서는 꼭 짚고 넘어가야한다고 생각합니다.

[http://developer.android.com/intl/ko/design/patterns/navigation.html](http://developer.android.com/intl/ko/design/patterns/navigation.html)

![]({{ site.url }}/assets/images/20160525/4.png)

구현 방법은 [여기](http://developer.android.com/intl/ko/training/implementing-navigation/ancestral.html)서 확인할 수 있습니다.

### 결론

[http://developer.android.com/intl/ko/index.html](http://developer.android.com/intl/ko/index.html)에 있는 정보는 API 레퍼런스를 포함해서 꽤 중요한 자료들이 많기 때문에, 시간이 있을 때 읽어두는 편이 좋습니다.

## 태블릿과 화면 회전에 대응

Android는 iOS와는 다르게 AndroidManifest.xml에서 "이 앱은 태블릿용 애플리케이션입니다."라고 선언하지 않아도 보통 태블릿에서 사용할 수 있도록 되어있습니다. 하지만 Google Play 스토어를 보면 "이 애플리케이션은 태블릿용으로 설계되었습니다."라고 되어있지 않으면 랭킹에 올라가지 않는 등의 문제가 있습니다.

사실 이것은 옛날에는 태블릿용 스크린샷을 등록하는 것만으로도 괜찮았지만, 최근에는 사람이 직접 레이아웃을 일일히 체크하는 것 같습니다.

Fragment의 사용 방법

[http://developer.android.com/intl/ko/guide/practices/tablets-and-handsets.html#Fragments](http://developer.android.com/intl/ko/guide/practices/tablets-and-handsets.html#Fragments)

[http://qiita.com/HideMatsu/items/ddf640899cbe1b2027ed](http://qiita.com/HideMatsu/items/ddf640899cbe1b2027ed) (일본어)

## 좀 더 테크니컬한 이야기

### Support Library의 최신 변경 사항

Android에서는 처음부터 사용 가능한 Fragment와 Support Library 안에 있는 Fragment로 Fragment 구현이 두가지가 있었는데, Google 직원분께서 하신 말로는 최신 기능과 버그 수정을 위해 항상 Support Library의 구현을 쓰는 것을 권장한다는 이야기를 듣고(DroidKaigi 2016 2일차 기조연설에서) Support Library의 구현체를 반드시 사용해야 한다고 생각하게 되었습니다.

하지만, 버전 업으로 인하여 사양이 변경되는 일(메소드가 없어지거나)이 있을 수가 있어 주의가 필요합니다. Android Studio가 업데이트를 하라고 노란색 밑줄을 표시하고 있지만, 꾹 참으시고 우선 아래 페이지에서 어떤 사항이 바뀌었는지를 체크하고 업데이트하는 것이 바람직합니다.

[http://developer.android.com/intl/ko/tools/support-library/index.html](http://developer.android.com/intl/ko/tools/support-library/index.html)

### Android Framework의 API Diff

Android의 compileSdkVersion을 올리면 메소드가 사라지는 일이 발생합니다. 최근같은 경우 Notification.Builder의 serLatestEventInfo() 메소드(API 23)가 없어져서 [한바탕 소동](http://stackoverflow.com/questions/32345768/cannot-resolve-method-setlatesteventinfo)이 일어났습니다.

Google이 Android API Differences Report를 내고 있기 때문에 이걸 보면 각 버전에서 어떤 인터페이스가 바뀌었는지 확인할 수 있습니다.
[http://qiita.com/takahirom/items/b46afb73a5c8429d8675](http://qiita.com/takahirom/items/b46afb73a5c8429d8675) (일본어)

### 편리한 라이브러리 목록
- [wasabeef/awesome-android-ui](https://github.com/wasabeef/awesome-android-ui) ← UI 라이브러리 목록은 정말 편리합니다.
- [http://qiita.com/KeithYokoma/items/b5b53c94f6ab27b604e7](http://qiita.com/KeithYokoma/items/b5b53c94f6ab27b604e7)

이거 외에도 Qiita에 글이 많이 올라와있습니다.

### 라이브러리를 도입할 때 유용한 사이트

대부분의 라이브러리는 GitHub의 README.md에 적혀져 있습니다만, 우선 build.gradle에 무엇을 추가하면 좋을지를 찾으려면 [http://mvnrepository.com](http://mvnrepository.com)이 편리합니다. 일부 라이브러리는 Maven Central 대신 jCenter에만 업로드 되는 것이 있기 때문에 이런 라이브러리는 [bintray](https://bintray.com/bintray/jcenter)에서 찾지 않으면 안됩니다.

그렇다고 해서, 뭐든 좋다고 휙휙 쓸 수 있는게 아니라 넣으면 넣을수록 빌드 시간이 길어집니다. [http://methodscount.com](http://methodscount.com)을 사용하면 build.gradle을 복사해서 붙여넣으면 라이브러리의 크기와 메소드의 수를 알려줍니다. (Android Studio 플러그인도 있습니다!)

여담이지만, [bintray-release](https://github.com/novoda/bintray-release)를 사용하면 jCenter 라이브러리를 몇 번의 클릭으로 공개할 수 있으므로 꼭 공개하고 갑시다.

## 어찌됬던 일단 소스 코드를 읽는다.

<blockquote class="twitter-tweet" data-lang="ko"><p lang="en" dir="ltr">Android development is about 10% writing Java. The other 90% is reading, crying, debugging, and pressing alt+enter</p>&mdash; Jon F Hancock (@JonFHancock) <a href="https://twitter.com/JonFHancock/status/702973001600364544">2016년 2월 25일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

울며 겨자먹기로 코드를 읽고, Alt + Enter를 연타하는 것이 안드로이드 개발입니다. URL 등을 이야기했지만 코드를 읽는 것이 안드로이드 개발입니다. 중요하니까 두번 말했습니다. 우선 문제가 있으면 공식 이슈 트래커 등에 찾아보고, 나오지 않을 경우 아래의 URL을 이용해서 SDK 소스 코드를 읽을 수 있습니다.

 - [소스 코드 검색 (OpenGrok)](https://sites.google.com/site/devcollaboration/codesearch)
 - [GitHub의 안드로이드 미러](https://github.com/android)
	 - [Android Framework의 Mirror Repository](https://github.com/android/platform_frameworks_base)
	 - [Support Library의 Mirror Repository](https://github.com/android/platform_frameworks_support)
 - Android Studio SDK의 소스 코드를 참조해서 읽는 방법 [(조금 낡은 기사)](http://qiita.com/makoto_kw/items/032e210aecf57deeb5a5)



### 샘플 애플리케이션과 읽어봐야 할 부분

konifar 씨의 DroidKaigi 2016의 애플리케이션은 간단하게 정보를 표시하고 즐겨찾기 등을 관리할 수 있는 샘플 응용 프로그램으로 매우 깨끗한 코드라고 정평이 나 있습니다. 우리들의 신, Jake Wharton 씨의 u2020도 일부를 차용했다는 이야기를 간혹 듣기 때문에 분명 뭔가 얻을 수 있을 것입니다. 확인하니 RxJava라던가 Retrofit 2 등의 현대적인 구성으로 되어있는 것 같습니다.

ActivityThread나 FragmentManager쪽은 생명주기와 관련해서 제대로 문서화되지 않은 동작(화면 회전 시, 처음부터 끝까지 다른 처리를 Main Thread에서 하는 것인지 궁금한 소박한 의문 등…)을 확인하기 위해 읽어둘 필요가 있을지도 모릅니다. 저는 읽게 되었습니다.

[https://github.com/android/platform_frameworks_base/blob/master/core/java/android/app/ActivityThread.java](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/app/ActivityThread.java)
[https://github.com/android/platform_frameworks_support/blob/master/v4/java/android/support/v4/app/FragmentManager.java](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/app/ActivityThread.java)

## 마치며
 일본에서는 iOS 사용자가 많기 때문인지 iOS 개발자가 더 우세하고 Android는 iOS의 디자인 카피같은 시안도 많이 받고 외롭습니다. Android 다운 멋진 애플리케이션을 늘려갑시다.