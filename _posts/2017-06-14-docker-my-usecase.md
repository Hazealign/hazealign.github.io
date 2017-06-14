---
layout: post
title: "내가 Docker를 시작했던 방법"
date: 2017-06-14 12:00:00
categories: Code
tags: docker 도커 container kubernetes mesosphere watchtower 배포 자동화
---

요즘 세상에 Docker를 들어보지 않은 소프트웨어 개발자는 꽤나 드물 것이다. Docker가 컨테이너를 이용한 격리 환경을 만들어주고, 배포나 관리 등에 이점이 있다는걸 알고 있는 사람도 많지만 그럼에도 불구하고 Docker를 쓰기엔 주저하는 일이 많다. 필자 또한 최근까지 Docker가 어려운 존재라고 생각했었고 지금까지 도입하는걸 주저하고 있었다. 필자는 "이번엔 무슨 일이 있어도 내가 Docker를 써봐야겠다!"라는 일념으로 새로 시작하는 프로젝트에 Docker를 도입하게 되었는데 이게 생각보다 너무 간단한 일이었기 때문에 이번 글에서는 필자가 어떻게 Docker를 시작하게 되었는지를 공유하려고 한다. 

이 글은 Docker가 무엇인지는 알고 있다는 전제 하에 써진 글이므로, Docker가 무엇인지 잘 모른다면 이재홍님의 [가장 빨리 만나는 도커 1장](http://pyrasis.com/book/DockerForTheReallyImpatient/Chapter01)을 읽는걸 추천한다. 이 글만 잘 따라해도 아래 사진처럼 커밋이 올라가면 CI가 Docker 이미지를 만들어서 업로드하고 서버에 배포까지 하는 플로우를 구성할 수 있다.

![]({{ site.url }}/assets/images/20170614/dockerhub_example.png)

![]({{ site.url }}/assets/images/20170614/travis_example.png)

## 설치가 반이다.

시작이 반이라는 말처럼, Docker도 설치가 반이다. Docker가 리눅스 컨테이너 기술에서 시작된 물건이다보니, 리눅스에서는 옛날부터 설치가 그렇게 어렵지 않았지만 Windows와 macOS 환경에서는 제대로 Docker를 사용하려면 최신 운영체제를 써야하는 번거로움이 있다. 예전에는 리눅스가 아닌 운영체제에서는 Boot2Docker나 Docker Toolbox라는걸 통해 작은 리눅스 가상머신을 올려놓고 그 위에서 Docker가 돌아갔었다.

- macOS에서 Docker는 [xhyve](https://github.com/mist64/xhyve)를 이용한다. xhyve는 macOS를 위한 경량 가상화 환경으로 `Hypervisor.framework`라는 10.10 Yosemite부터 추가된 애플의 API를 사용한다. 
- Windows에서 Docker는 윈도우 컨테이너와 Hyper-V 컨테이너 기술을 이용한다. Windows 10 Anniversary Edition부터 이를 지원하며, 윈도우10(Pro, Enterprise 에디션) 혹은 윈도우 서버 2016에서만 지원한다.

애석하게도 필자가 일하는 곳의 개발 서버 환경은 아직 윈도우 서버 2008 ~ 2012이다. 이럴 때는 VirtualBox나 Hyper-V를 이용하는 Docker Toolbox를 설치해야한다. 인스톨러가 잘 되어있는 편이라, 윈도우나 맥에서는 인스톨러대로 설치하면 별 문제 없이 설치할 수 있을 것이다.

## 기존 서버 프로젝트를 Docker로 감싸다.

필자가 Docker를 도입한 프로젝트는 Kotlin으로 된 Vert.x 서버였다. 프로젝트가 좀 활발한 프레임워크라면 대부분 Docker 이미지를 빌드하는 방법들을 문서로 제공한다. Vert.x도 [이 글](http://vertx.io/docs/vertx-docker/)을 통해 기본적인 Docker를 쓰기 위한 가이드를 제공한다. 하지만 필자의 프로젝트는 Maven이 아니고 Gradle로 빌드를 관리하기도 하고, 그대로 쓰기엔 무리가 있었다.

다행히 Gradle에도 Docker를 지원하는 플러그인이 있다. 두개가 있고, 둘 다 비슷한 Star 수를 가지고 있다.

- [Transmode/gradle-docker](https://github.com/Transmode/gradle-docker)
- [bmuschko/gradle-docker-plugin](https://github.com/bmuschko/gradle-docker-plugin)

필자는 [이 글](https://github.com/advantageous/vertx-node-ec2-eventbus-example/wiki/Step-7-Adding-docker-support-to-gradle-and-deploying-our-image-to-Mesos-Marathon#add-docker-support-to-gradle)을 참조했고, `buildscript.dependencies`에 `gradle-docker` 플러그인을 추가한 것 이외에는 다음 코드만으로 Docker 이미지를 생성할 수 있게 되었다.

{% highlight groovy %}
docker {
baseImage "vertx/vertx3-exec"
maintainer 'Haze Lee "hazelee@realignist.me"'
registry
}

task buildDocker(type: Docker) {
tagVersion = System.getenv("COMMIT") ?: project.version
push = Boolean.getBoolean("docker.push")
applicationName = "realignist/..."
tag = "${applicationName}"

addFile {
from "${project.shadowJar.outputs.files.singleFile}"
into "/opt/hello/"
}
exposePort 8080
entryPoint = ["sh",  "-c"]
defaultCommand = ["java -jar /opt/hello/${project.name}-${project.version}-fat.jar"]
}
{% endhighlight %}

똑같이 jar 파일로 뽑아내서 실행할 수 있는 환경이라면 설정은 이와 크게 다르지 않을 것이다. 미리 Docker Hub에 로그인을 하고 프로젝트를 미리 만들어뒀다면, 다음 커맨드만으로 이미지 빌드부터 Docker Hub로의 업로드까지 한번에 할 수 있다.

{% highlight shell %}
> gradle -Ddocker.push=true build shadowJar buildDocker
{% endhighlight %}

## 자동으로 이미지를 만들자.

놀랍게도 DockerHub는 GitHub 연동을 통해 자동으로 이미지 빌드를 뽑아낼 수 있다. [이 문서](https://docs.docker.com/docker-hub/builds/)에 자세히 나와있는데, Dockerfile이 프로젝트 안에 있어야하고 또 많은 프로젝트들이 의존성 관계도 있기 때문에 이 기능을 그대로 쓰기는 어렵다. 하지만 우리에겐 Travis나 CircleCI같은 CI 서비스가 있고 우리는 이걸 활용하면 커밋에 따라 자동으로 이미지를 만들고 업로드할 수 있다.

{% highlight yaml %}
sudo: false
language: java
jdk:
- oraclejdk8

services:
- docker

before_script:
- chmod +x gradlew

before_install:
- docker login -e="$DOCKER_EMAIL" -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

script:
- gradle -Ddocker.push=true build shadowJar buildDocker

env:
global:
- COMMIT=${TRAVIS_COMMIT::7}

branches:
only:
- master
{% endhighlight %}

위 yaml 파일은 필자가 실제로 쓰고 있는 Travis 셋팅 파일이다. Travis의 프로젝트 셋팅에서 DockerHub의 계정 정보(`$DOCER_EMAIL`, `DOCKER_USERNAME`, `DOCKER_PASSWORD`)를 미리 지정해두면 `master` 브랜치에 새 커밋이 올라올 때마다 이미지를 빌드하고 업로드한다. gradle 코드 부분을 보면 알겠지만 `COMMIT`이라는 이름의 환경변수가 있으면 생성되는 도커 이미지의 버전을 이 환경변수로 올리도록 해놨기 때문에, `env.global`에 `COMMIT`이라는 환경변수를 추가해뒀다. 저렇게 `${TRAVIS_COMMIT::7}`이라 표현해두면 빌드가 실행되는 프로젝트 마지막 커밋의 해쉬값에서 7자만 따오는게 된다.

또 `before_script`의 chmod는 CI 환경에서 gradle로 빌드하기 위해서 프로젝트에 있는 `gradlew` 파일에 권한을 주는 것이다. Travis는 gradle 프로젝트에서는 자동으로 `gradlew assemble`를 실행하기 때문에, chmod로 권한을 주지 않으면 빌드 오류가 발생한다.

## 자동으로 업데이트되는 환경을 만들자.

![]({{ site.url }}/assets/images/20170614/google_docker_deploy.png)

구글에 Docker를 쳐보면 수많은 배포 자동화 사례들을 볼 수 있다. 대부분 DockerHub로 이미지를 배포하는 부분에서 글이 끝나는데 나는 정말로 실제 쓰고 있는 스테이징 혹은 릴리즈 서버에 새 이미지가 자동으로 올라가게 하는 것까지 이야기해보고 싶다.

실제 서비스 환경에서는 확장성을 위해 컨테이너를 여러 개 쓰는 경우도 있다. 인스턴스가 하나라면 그냥 들어가서 수동으로 이미지를 받고 다시 올리는 방법도 있겠지만, 여러 대의 서버가 있다면 이걸 자동화해야한다. 선택지가 꽤 많고 정답이 없기 때문에 도구는 자신이 선택하면 될 것 같다.

- [v2tec/watchtower](https://github.com/v2tec/watchtower)는 DockerHub 등에서 베이스 이미지가 업데이트되면 그걸 감지해서 새 이미지를 받아서 재시작해주는 툴이다. 처음 시작할 때만 셋팅해주면 되기 때문에 서버 노드가 적을 때 고려해볼 수 있다. 
- 만약 노드 수가 늘어난다면… 이제 정말로 여러 컨테이너를 관리해주는 Container Orchestration 도구가 필요할 것이다.
- Docker에서 클러스터를 위해 [Swarm](https://docs.docker.com/engine/swarm/)이라는 도구를 자체적으로 제공하지만 아직은 3rd 파티 도구가 더 많이 쓰이는 것 같다. Swarm에 관심이 있다면 [subicura님의 글](https://subicura.com/2017/02/25/container-orchestration-with-docker-swarm.html)을 강력 추천한다.
- [Kubernetes](https://kubernetes.io/)는 구글 클라우드에서 도커 컨테이너를 관리해주기 위해 만든 오픈소스 도구이다. 로컬 머신이나 싱글 노드에서는 Minikube를 통해 로컬에서도 실행할 수 있다.
- https://www.slideshare.net/seungyongoh3/ndc17-kubernetes
- https://www.slideshare.net/naver-labs/docker-kubernetes
- https://1ambda.github.io/infrastructure/container/kubernetes-intro/
- 트위터나 Airbnb, 애플[^1], 우버 등이 쓰고 있는 분산 시스템 커널인 아파치의 [Mesos](http://mesos.apache.org/)도 있다. [Mesosphere](https://mesosphere.com/solutions/container-orchestration/)라는 회사에서 만든 [Marathon](https://github.com/mesosphere/marathon)을 통해 컨테이너를 관리할 수 있다. 
- Mesos는 [Zookeeper](https://zookeeper.apache.org/)를 이용해서 여러 대의 서버를 하나의 클러스터로 관리한다.
- [mesos/chronos](https://github.com/mesos/chronos)를 통해 스케쥴링을 돌릴 수 있다.
- 설치와 관리가 비교적 어려운 편이다.

필자의 프로젝트는 아직 릴리즈되지 않았기 때문에 아직은 개발 환경에서 watchtower만 쓰고 있다. 다음과 같은 커맨드로 watchover를 구성할 수 있다.

{% highlight shell %}
# watchover를 실행하기 전에 먼저 프로젝트의 docker container를 실행해야한다.
# 이 커맨드를 실행하면 watchover 컨테이너에서 실행 중인 다른 모든 컨테이너들을 모니터링할 것이다.
> docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
v2tec/watchtower
{% endhighlight %}

## 후기

뭔가 한게 없는 것 같지만, 아니 실제로도 Docker의 설치를 제외하곤 `build.gradle`와 `.travis.yml`  몇 줄 추가했을 뿐이다. 이제 열심히 개발해서 master 브랜치로 커밋을 머지하면, CI가 Docker 이미지를 만들어서 업로드하고 이 이미지는 자동으로 서버로 올라가게 된다. 물론 나중에 프로젝트가 커지면 여러 실행 환경들을 Dockerfile에 담아야하니 설정이 더욱 복잡해지긴 하겠지만, 마치 하스켈의 [모나드 괴담](https://e.xtendo.org/haskell/ko/monad_fear/slide#1)처럼 Docker는 어쩌면 사람들이 아니 내가 너무 어렵게 생각해온 것 같다. 이 글을 통해 독자도 자신의 프로젝트에 도커를 적용할 수 있었으면 좋겠다.

이렇게 짧은 삽질을 하기까지 구글신과 기존 플러그인들의 도움을 많이 받았고, 이재홍님의 [Docker 책](http://pyrasis.com/private/2014/11/30/publish-docker-for-the-really-impatient-book)과 [슬라이드](https://www.slideshare.net/pyrasis/docker-fordummies-44424016)가 큰 도움이 되었다. 이미 책을 가지고 있지만, 책의 원고를 또 인터넷에 공개해주셔서 또 편하게 읽을 수 있었다.

[^1]: 애플은 전 세계에서 쓰이는 시리를 위해 Mesos와 애플 내부의 커스텀 스케쥴러인 JARVIS를 쓰고 있다.
