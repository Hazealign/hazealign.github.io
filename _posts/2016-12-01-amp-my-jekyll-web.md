---
layout: post
title: "지킬 블로그에 AMP를 적용해보자"
date: 2016-12-01 18:00:00 +09:00
categories: Code
tags: development amphtml amp jekyll amp-jekyll amplify 
---

항상 그렇지만 사람이 백수가 되면 심심해지고, 사람이 잉여로워지면 무언가 재미난 것을 하게 된다. 오늘은 지킬 블로그에 AMP(Accelerated Mobile Pages) 페이지를 넣은 후기를 쓰려고 한다. 이 글은 AMP가 무엇인지 아는 사람을 위해 작성된 글로, AMP에 대한 설명과 소개는 [여기](https://www.ampproject.org/ko/learn/about-amp/)에서 볼 수 있다.

### 천리길도 Travis부터.

사실 지금 보고 있는 이 웹 페이지는 GitHub Pages에서 돌아가고 있다. GitHub Pages는 기본적으로 Jekyll을 지원하기 때문에 소스 코드만 GitHub에 올리면, 알아서 웹에서 생성된 html 파일을 볼 수 있다. 하지만 GitHub Pages는 외부 플러그인을 지원하지 않는 안전 모드로 동작하기 때문에, 나는 AMP를 적용하기 위해 html만이 있는 브랜치와 소스 코드가 있는 브랜치를 분리하게 되었다.

item4님도 Travis로 블로그를 설정하셨길래 어떻게 셋팅했나 보니까 Lektor는 손쉽게 GitHub로 생성된 html만을 Deploy할 수 있었다. 아…! 셋팅하기 너무 귀찮았지만, 백수니까 그냥 셋팅했다. 내 빌드 스크립트는 [여기](https://github.com/Hazealign/hazealign.github.io/blob/src/scripts/deploy.sh)에서 볼 수 있다. (블로그 커밋 로그가 엉망이니까 로그는 보지 않는걸 권장한다...)

#### 참고했었던 스크립트들이다.

- [처음에 뼈대로 쓴 것](https://gist.github.com/domenic/ec8b0fc8ab45f39403dd)
- [그 이후에 참고한 것 ](http://eshepelyuk.github.io/2014/10/28/automate-github-pages-travisci.html)

아, 기분 좋게 Travis가 연동됬다. 이제 Jekyll에 플러그인을 이것저것 넣을 수도 있으니 AMP 플러그인을 넣어보기로 한다.

### amp-jekyll과 amplify 

amp-jekyll과 amplify를 소개하기 전에 우선 고백한다. 내 블로그는 끄-음찍한 혼종이다. 상단 부분의 헤더는 amplify를 참고했고, 기본적으로 amp html을 생성하는 것은 amp-jekyll을 이용하고 있다. 내가 웹을 제대로 개발하는 사람은 아니기 때문에 내 블로그는 그만 알아보자…

[amp-jekyll](https://github.com/juusaw/amp-jekyll)은 jekyll 플러그인 형태로 amp html을 생성시키는 프로젝트다. 또 [amplify](https://github.com/ageitgey/amplify)는 amp html을 만들어내는 하나의 jekyll 테마이다. 나는 이미 만들어두고 쓰고 있는 베이스 jekyll 테마가 있었기 때문에 amp html에서만 amplify를 살짝 참고하고, amp html 베이스는 amp-jekyll로 만들었다. amp-jekyll을 약간 수정했는데 내 프로젝트의 `_posts` 구조에 맞게 바꾼 것과 [Pull Request 하나](https://github.com/juusaw/amp-jekyll/pull/14/files)를 체리픽한게 끝이다.

### 하면서 디버깅은 어떻게 했는가.

다른 amp html을 개발할 때랑 똑같이 amp 페이지 url 뒤에 `#development=1`를 넣어주면 된다. 매우 심플하다. 그러면 amp validation이 동작할 것이다.

또, 중간에 [이 PR](https://github.com/juusaw/amp-jekyll/pull/11)을 체리픽 했었는데 문제가 있었다. `amp-img` 태그에는 기본적으로 이미지의 width와 height가 명시되어야하기 때문에 fastimage라는 모듈을 써서 이미지의 원본 사이즈를 가져오는데, 여기가 제대로 동작하지 않았었다. 한가지 더, amp html은 url 맨 끝에 `.html` 확장자를 붙으면 에러가 난다. 참고하자.

### 그래서 내 AMP 페이지는 어떻게 보일까?

![스크린샷]({{ site.url }}/assets/images/20161201_1.png)

대충 이렇게 보인다. 디자인적으로는 아쉽긴 하지만, 모바일에서 검색했을 때 빨리 보인다는 메리트 때문에 AMP를 쓰는거라서 크게 거슬리거나 하지는 않았다. 이제 구글 검색이 AMP 검색 결과를 보여주길 기다리면… 될 것 같다. :D