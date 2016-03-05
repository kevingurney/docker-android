FROM ubuntu:latest
MAINTAINER Kevin Gurney <kevin.p.gurney@gmail.com>

ARG ANDROID_SDK_TOOLS_VERSION=24.4.1
ARG ANDROID_BUILD_TOOLS_VERSION=23.0.2
ARG ANDROID_API_LEVELS=android-19,android-21,android-22,android-23
ARG GRADLE_VERSION=2.11
ARG JAVA_VERSION=7

WORKDIR /opt

RUN dpkg --add-architecture i386 && apt-get update && apt-get install --yes \
    libncurses5:i386 \
    libstdc++6:i386 \
    zlib1g:i386 \
    wget \
    unzip \
    openjdk-${JAVA_VERSION}-jdk && \
    wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle-${GRADLE_VERSION}-bin.zip && \
    rm gradle-${GRADLE_VERSION}-bin.zip && \
    wget http://dl.google.com/android/android-sdk_r${ANDROID_SDK_TOOLS_VERSION}-linux.tgz && \
    tar xzf android-sdk_r${ANDROID_SDK_TOOLS_VERSION}-linux.tgz && \
    rm android-sdk_r${ANDROID_SDK_TOOLS_VERSION}-linux.tgz && \
    echo "y" | /opt/android-sdk-linux/tools/android update sdk --no-ui --filter ${ANDROID_API_LEVELS},build-tools-${ANDROID_BUILD_TOOLS_VERSION},platform-tools && \
    groupadd --gid 1000 --system default && \
    useradd --gid 1000 --uid 1000 --system --create-home default

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64 \
    GRADLE_HOME=/opt/gradle-${GRADLE_VERSION} \
    ANDROID_HOME=/opt/android-sdk-linux

ENV PATH=$PATH:${JAVA_HOME}/bin:${GRADLE_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:${ANDROID_HOME}/platform-tools

USER default
