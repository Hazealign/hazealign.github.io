---
layout: post
title: "Kotlin 코드를 문서화하자. (for Android)"
date: 2016-06-24 19:30:00 +0900
categories: Code
tags: android kotlin development documentation kdoc dokka
---

처음 내가 Kotlin을 접할 때만 하더라도 많은 사람들이 Kotlin의 존재를 모르고 있었다. 그리고 Kotlin을 이리저리 설파하려고 하는 나조차도 최근에서야 나도 실무에서 Kotlin을 제대로 쓸 수 있게 되었다. 다른 사람과 협업을 할 때, 문서화는 중요하다. 내가 문법이나 이런걸 프로젝트에 문서화해둘 수는 없어도 프로젝트 안 클래스나 메소드, 프로퍼티들이 어떤 역할을 하고 있는지는 남길 수 있다.
 
그래서 오늘은 실전 안드로이드 프로젝트에서 어떻게 Kotlin 코드를 문서화할 수 있는지에 대해서 이야기해보고자 한다. 나는 안드로이드 프로젝트를 기준으로 설명하고 있지만, 기본적으로는 Gradle 기반의 프로젝트라면 이 글이 도움이 되리라 믿는다.
 
## KDoc을 남기는 방법

KDoc은 Kotlin의 Javadoc같은 개념이라고 생각하면 된다. `/**`로 시작해서 `*/`로 끝이 난다. 여러 줄인데 매 줄마다 아스테리크 문자가 들어가는 형태이다. Kotlin 공식 문서가 제공하는 예시를 보자.

{% highlight kotlin %}
/**
 * A group of *members*.
 *
 * This class has no useful logic; it's just a documentation example.
 *
 * @param T the type of a member in this group.
 * @property name the name of this group.
 * @constructor Creates an empty group.
 */
class Group<T>(val name: String) {
    /**
     * Adds a [member] to this group.
     * @return the new size of the group.
     */
    fun add(member: T): Int { ... }
}
{% endhighlight %}

그리고 KDoc은 인라인 마크업에 대해서는 C#의 xml같은 형태가 아니라 마크다운 문법을 따라하고 있다. 그리고 약간 특이한 점은 요런 식으로의 클래스, 프로퍼티, 메소드의 링킹이 가능하다.

`Use [this method][doSomething] for this purpose.`

블록 태그를 지원하며 이 부분은 Javadoc과 굉장히 유사한데, Kotlin에서는 다음과 같은 블록 태그를 지원한다. 그리고 `deprecated` 태그가 먹히지 않기 때문에 이 부분은 `Deprecated` 어노테이션을 달아줘야한다.

 - param
 - return
 - constructor
 - property 
 - throws, exception 
 - sample
 - author
 - since
 - suppress

## Gradle에서 Dokka로 Kotlin 문서를 Export하는 방법

- 루트 프로젝트의 `build.gradle`을 열어 다음과 같이 추가한다.

{% highlight groovy %}
buildscript {
    ...
    
    repositories {
        mavenCentral()
        jcenter()
        maven {
            url 'https://dl.bintray.com/kotlin/kotlin-eap'
        }
    }

    dependencies {
	    ...
	    classpath "org.jetbrains.dokka:dokka-android-gradle-plugin:0.9.8"
	    ...
    }
}

...
{% endhighlight %}

 - 앱 혹은 라이브러리 프로젝트의 `build.gradle`을 다음과 같이 설정한다.

{% highlight groovy %}
...
apply plugin: 'org.jetbrains.dokka-android'

android {...}

afterEvaluate {
    generateDebugAndroidTestSources.dependsOn dokka
    ...
}

...

dokka {
    moduleName = '...'
    outputFormat = 'html'
    outputDirectory = "$projectDir/docs"
    processConfigurations = [ 'compile' ]
    linkMapping {
        dir = "src/main/kotlin"
        url = "https://github.com/.../.../blob/master/app/src/main/kotlin"
        suffix = "#L"
    }
    sourceDirs = files('src/main/kotlin')
}

...
{% endhighlight %}

Dokka의 상세한 정보는 [GitHub](https://github.com/Kotlin/dokka)에서 볼 수 있다. `afterEvaluate`에, `generateDebugAndroidTestSources`는 `dokka`에 의존 관계를 갖는다고 명시했기 때문에 프로젝트를 빌드할 때 문서는 자동으로 생성될 것이다.

## 커스텀 Stylesheet를 적용하는 방법

- 빌드가 끝나면 css와 html 파일이 나오는데 화면의 스타일시트를 수정하고 싶을 때는  Dokka의 소스를 열...뻔 했지만 생각해보니 생성이 끝나고 css 파일만 바꿔치기해주면 된다는 방법을 깨닫고 짜치게 구현해봤다. 앱이나 라이브러리 프로젝트의 `build.gradle` 파일을 수정해보자.

{% highlight groovy %}
...
apply plugin: 'org.jetbrains.dokka-android'

android {...}

task switchStylesheet (type: Copy, overwrite: true) {
    description = 'Switching StyleSheet for Dokka'
    from "${projectDir}/dokka/"
    include "style.css"
    into "${projectDir}/docs/"
}

afterEvaluate {
    generateDebugAndroidTestSources.dependsOn switchStylesheet
    switchStylesheet.dependsOn dokka
    ...
}

dokka {...}

...
{% endhighlight %}
 
- `switchStylesheet`라는 task를 만들었다. 얘는 `dock` 태스크가 끝나면 실행되도록 의존성이 설정되어있고, 디버그 소스를 빌드할 때는 `switchStylesheet`에 의존성을 걸어주면 자연스럽게 동작하게 된다.
- 프로젝트 디렉토리에 dokka 폴더를 만들고, 그 안에 css 파일을 넣으면 잘 동작할 것이다.

## Profit!

![](/assets/images/20160624/1.png)

이렇게 깔끔하게 문서가 나온다! 이렇게 나오는 문서를 보니 기분이 너무 조크든요... 개인적으로 클린한 코드를 짰을 때, 좋은 문서를 봤을 때, 문서화를 잘 했을 때 기분이 너무 좋다. 넘나 좋은 것.
 
## Reference

  - [https://kotlinlang.org/docs/reference/kotlin-doc.html](https://kotlinlang.org/docs/reference/kotlin-doc.html)
  - [https://github.com/Kotlin/dokka](https://github.com/Kotlin/dokka)
