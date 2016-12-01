---
layout: post
title: "macOS 기준 Rust에서 OpenSSL과 관련된 빌드 오류 해결하기"
date: 2016-10-01 01:00:00 +09:00
categories: Developmente
tags: featured development rust openssl 
---

Rust로 OpenSSL과 연결된 것들을 빌드할 때, 간혹 다음과 같은 에러를 볼 수 있습니다.

```
--- stderr
/…/openssl-sys-0.6.4/src/openssl_shim.c:1:10: fatal error: 'openssl/hmac.h' file not found
#include <openssl/hmac.h>
         ^
1 error generated.
```

이럴 때는 다음과 같이 해결할 수 있습니다.

{% highlight bash %}
brew install openssl

 # 다음 내용을 환경 변수로 추가해주세요.
export OPENSSL_INCLUDE_DIR=`brew --prefix openssl`/include/
export OPENSSL_LIB_DIR=`brew --prefix openssl`/lib/
{% endhighlight %}

이럼에도 불구하고, 간혹 같은 에러가 난다면 `OPENSLL_LIB_DIR`를 직접 설정해주면 됩니다.

{% highlight bash %}
export OPENSSL_INCLUDE_DIR=/usr/local/Cellar/openssl/(버전)/include/
{% endhighlight %}

아 그리고 나서, `cargo clean`을 해주고 다시 빌드하는걸 잊지 마세요. :)

# Reference
 - [https://github.com/sfackler/rust-openssl](https://github.com/sfackler/rust-openssl)
 - [https://github.com/sfackler/rust-openssl/issues/255#issuecomment-133463099](https://github.com/sfackler/rust-openssl/issues/255#issuecomment-133463099)
