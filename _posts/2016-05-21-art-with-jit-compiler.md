---
layout: post
title: "JIT(Just-in-Time) 컴파일러도 들어간 ART를 살펴보자"
date: 2016-05-21 17:30:00 +0900
categories: Code
tags: android compiler llvm aot jit optimization android-runtime art featured
---

Android N부터 ART에 JIT(Just-in-Time) 컴파일러 기능이 추가되었다고 한다. 종래의 버전에서 ART는 AOT(Ahead-of-Time) 컴파일 방식을 통해 dex 바이너리를 oat 형식의 네이티브 바이너리로 컴파일했는데, N부터는 프로필 가이드를 기반한 컴파일을 통해 AOT 컴파일 방식과 JIT 컴파일 방식을 혼용해서 쓸 수 있게끔 변경된 것이다. JIT 컴파일러를 혼용함으로써 앱의 설치와 시스템 업데이트 시 걸리는 시간이 단축될 수 있다는게 구글의 설명이다.

프로필 가이드에 기반한 최적화는 프로파일링을 통해 런타임의 퍼포먼스를 높여주는 컴파일러의 최적화 기술이다. 그러면 ART는 언제부터 JIT 컴파일 기능이 추가가 되었는지, 어떻게 동작하는지 궁금한 나같은 사람들을 위해 같이 ART의 소스 코드와 커밋을 살펴보기로 하자.

## ART는 Kitkat부터 사용 빈도가 높은 메소드를 다시 컴파일했다.

아니 이게 무슨 소리인가. 실시간으로 컴파일을 하는 JIT는 Android N 런타임에 추가된 새로운 기능이다. 근데 ART가 시범적으로 적용됬었던 Android 4.4부터 비슷한 기능이 있었다니?

	I/art     (  636): DexFile_isDexOptNeeded size of new profile file /data/dalvik-cache/profiles/com.android.launcher is significantly different from old profile file /data/dalvik-cache/profile-cache/com.android.launcher (top 90% samples changed in proportion of 18.75%)
	I/PackageManager(  636): Running dexopt on: com.android.launcher
	I/dex2oat ( 1047): dex2oat: /system/bin/dex2oat --zip-fd=6 --zip-location=/system/priv-app/Launcher2.apk --oat-fd=7 --oat-location=/data/dalvik-cache/system@priv-app@Launcher2.apk@classes.dex --profile-file=/data/dalvik-cache/profiles/com.android.launcher
	 ...
	I/dex2oat ( 1047): compiling method android.view.View com.android.launcher2.PagedView.getPageAt(int) because its usage is part of top 3.08642% with a percent of 0.205761%
	I/dex2oat ( 1047): compiling method void com.android.launcher2.AppsCustomizeTabHost.onFinishInflate() because its usage is part of top 0.617284% with a percent of 0.617284%
	I/dex2oat ( 1047): compiling method void com.android.launcher2.CellLayout.<init>(android.content.Context, android.util.AttributeSet, int) because its usage is part of top 2.88066% with a percent of 0.411523%
	I/dex2oat ( 1047): compiling method void com.android.launcher2.CellLayout.onDraw(android.graphics.Canvas) because its usage is part of top 3.08642% with a percent of 0.205761%
	 ...
	I/dex2oat ( 1047): compiling method void com.android.launcher2.Workspace.addInScreen(android.view.View, long, int, int, int, int, int, boolean) because its usage is part of top 3.08642% with a percent of 0.205761%
	I/dex2oat ( 1047): dex2oat took 3.496627214s (threads: 1)
	I/art     ( 1019): Starting profile with period 10s, duration 30s, interval 10000us.  Profile file /data/dalvik-cache/profiles/com.android.launcher

Android 4.4에서 ART 방식으로 런타임을 사용할 때 볼 수 있는 로그의 일부분이다. 로그를 보면 별도의 쓰레드에서 프로파일링을 하고, 그 결과에 따라 많이 실행되는 메소드를 다시 컴파일하는걸 볼 수 있다. *[참고한 글](http://d.hatena.ne.jp/embedded/20140511/p1)*

[`runtime/profiler.cc`](https://android.googlesource.com/platform/art/+/39c3bfbd03d85c63cfbe69f17ce5800ccc7d6c13/runtime/profiler.cc)의 `void BackgroundMethodSamplingProfiler::Start(int period, int duration, ...)` 메소드와 [`compiler/driver/compiler_driver.cc`](https://android.googlesource.com/platform/art/+/39c3bfbd03d85c63cfbe69f17ce5800ccc7d6c13%5E%21/compiler/driver/compiler_driver.cc)의 `bool CompilerDriver::SkipCompilation(const std::string& method_name)` 메소드를 통해 위에 있는 로그가 어떻게 찍혔는지 알 수 있다.

지금 Marshmallow나 N의 소스 코드를 보면 `compiler/driver/compiler_driver.cc`에는 `CompilerDriver::SkipCompilation`라는 메소드가 존재하지 않을 것이다. 그러면 이 메소드는 언제 왜 없어졌는지에 대해서는 후술하도록 하겠다.

## JIT 컴파일러가 AOSP에 들어갔다!

정식으로 ART에 JIT 컴파일과 관련된 코드가 등록된 것은 2015년 2월의 일이다. [다음 커밋](https://android.googlesource.com/platform/art/+/2535abe7d1fcdd0e6aca782b1f1932a703ed50a4)을 보면 작년 2월부터 JIT의 기능을 시험적으로 써볼 수 있는걸 확인할 수 있다.

커밋이 큰데, diff를 보면 Runtime의 `IsCompiler()` 메소드의 이름이 `IsAotCompiler()`로 바뀐 것을 확인할 수 있다. AOT 컴파일과 JIT 컴파일을 구분하기 위함이라고 생각한다. 또, 해당 커밋의 [`runtime/runtime.cc`](https://android.googlesource.com/platform/art/+/2535abe7d1fcdd0e6aca782b1f1932a703ed50a4/runtime/runtime.cc#474) 코드를 확인해보자. SELinux의 R/W/X 메모리 구역 제한으로 인해 Zygote에서는 Code Cache가 만들어질 때까지는 JIT 컴파일을 사용하지 못한다는 것을 확인할 수 있다.

## Profile-Guided Optimization을 도입하다.

그 이후로 눈 여겨본 커밋은 Android N에서 도입되었다고 이야기하는 프로필 가이드에 기반한 최적화 컴파일을 가능하게 해주는 [커밋](https://android.googlesource.com/platform/art/+/500c9be)이다. 이 커밋의 diff를 확인해보면 위에서 언급했었던 `CompilerDriver::SkipCompilation` 메소드가 사라진 것도 확인할 수 있다.

일단 이 커밋을 통해 ART에서도 dex2oat 과정에서 프로필 가이드에 기반한 최적화가 가능해졌다. JIT를 수행하는 동안의 프로필 결과를 파싱할 수 있고, 프로필 정보에 존재하지 않는 메소드는 컴파일하지 않는다. 오래된 컴파일 훅은 삭제하며, dex2oat에서 인터프리팅 모드가 추가되었다.

아마 Android N에 추가되었다고 하는 프로필 가이드에 기반한 컴파일은 이 기능을 안정화시킨 것이라고 추측할 수 있을 것이다.

## 마치며

우리는 ART의 큼직큼직한 커밋들을 통해 처음엔 사용 빈도를 바탕으로 백그라운드에서 다시 컴파일을 하던 부분이 최적화를 거쳐 더 정교한 프로파일링을 바탕으로 JIT 컴파일 기능이 추가되었다라는걸 알 수 있었다. 사실 ART의 더 깊은 부분까지에 대해서는 아직 개인적으로도 이해가 부족하다는 생각이 들지만, 이 글을 통해 ART가 어떻게 발전할 수 있게 되었는지 이해하는데 조금이나마 도움이 되었으면 좋겠다.

**참고했었던 자료들**
 - [platform/art 소스 코드](https://android.googlesource.com/platform/art/)
 - [ART's Quick Compiler: An unofficial overview](http://www.slideshare.net/linaroorg/hkg15300-arts-quick-compiler-an-unofficial-overview)
 - [안드로이드의 ART는 실행 중에 프로파일링을 통해 백그라운드에서 다시 컴파일을 하는 것 같다.](http://d.hatena.ne.jp/embedded/20140511/p1)
 - [진화하는 ART](http://www.slideshare.net/kmt-t/art-47396171)