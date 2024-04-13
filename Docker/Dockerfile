# base가될 이미지 [ 알파인 리눅스가 가벼움 ]
FROM ubuntu:20.04

# 이미지 관리자 정보
LABEL maintainer="admin <address>"

# 컨테이너 안에서 명령어 실행
RUN apt-get update

ENV TZ=Asia/Seoul
RUN apt-get install -y tzdata

RUN apt-get install apache2 -y

# 로컬 디렉터리에서 읽어 들인 컨텍스트로부터 이미지에 파일을 복사
COPY index.html /var/www/html

# 명령어를 실행할 작업 디렉토리 지정
WORKDIR /var/www/html

RUN ["/bin/bash", "-c", "echo xoodb Docker Test >> index.html"]

# 컨테이너 실행시 Listen 할 포트 지정
EXPOSE 80

# 컨테이너 기동시 실행할 명령어 인수
CMD apachectl -DFOREGROUND

# 컨테이너 기동시 실행할 명령어
# ENTRYPOINT [ "executable" ]

# 파일을 이미지에 추가
# ADD source dest

# 명령어 실행 계정
# USER daemon