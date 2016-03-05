# Note: Currently, a number of Android SDK Tools do not work
# due to the need for 32 bit glibc support libraries.
FROM frolvlad/alpine-glibc:latest
MAINTAINER Kevin Gurney <kevin.p.gurney@gmail.com>

ARG ANDROID_SDK_TOOLS_VERSION=24.4.1
ENV ANDROID_SDK_TOOLS_VERSION=${ANDROID_SDK_TOOLS_VERSION}

ARG ANDROID_BUILD_TOOLS_VERSION=23.0.2
ENV ANDROID_BUILD_TOOLS_VERSION=${ANDROID_BUILD_TOOLS_VERSION}

ARG ANDROID_API_LEVEL=22
ENV ANDROID_API_LEVEL=${ANDROID_API_LEVEL}

ARG GRADLE_VERSION=2.11
ENV GRADLE_VERSION=${GRADLE_VERSION}

ARG JAVA_VERSION=7
ENV JAVA_VERSION=${JAVA_VERSION}

# The top-level parent directory for all manually installed tools related
# to Android development (e.g. Gradle, Android SDK Tools, etc.)
ENV DOCKER_ANDROID_HOME=/usr/local

ENV JAVA_HOME=/usr/lib/jvm/default-jvm \
    GRADLE_HOME=${DOCKER_ANDROID_HOME}/gradle-${GRADLE_VERSION} \
    ANDROID_SDK_TOOLS_HOME=${DOCKER_ANDROID_HOME}/android-sdk-linux

# ca-certificates needed for checking SSL connection when using wget to
# download Gradle binary distrbution.
# bash required for Gradle.
# ca-certificates required for HTTPS downloads (e.g. Gradle and Android SDK).
# openjdk${JAVA_VERSION} is required by Gradle.
RUN apk --no-cache add \
    bash \
    ca-certificates \
    openjdk${JAVA_VERSION}

# The Android Platform Tools downloaded using the Android SDK Manager are
# not compatible with musl libc.
# Update: glibc support is provided by frolvlad/alpine-glibc:latest.
# RUN apk --no-cache add android-tools --repository http://nl.alpinelinux.org/alpine/edge/testing

# According to Section 1.3.1 of their Certification Practices Statement, Google
# utilizes the external Root Certification Authority operated by GeoTrust Inc.
# The GeoTrust Global CA SSL certificate is needed by Java when the Android
# SDK manager connects to dl.google.com using HTTPS.
# See the following for additional information:
#   https://pki.google.com
#   https://www.geotrust.com/resources/root-certificates/
# services.gradle.org uses the COMODO ECC Certification Authority as its
# external Root Certification Authority.
# repo1.maven.org uses the DigiCert Global Root CA as its
# external Root Certification Authority.
RUN keytool -import -keystore ${JAVA_HOME}/jre/lib/security/cacerts -noprompt -storepass changeit \
    -file /etc/ssl/certs/ca-cert-GeoTrust_Global_CA.pem -alias "geotrust-global-ca" -trustcacerts && \
    keytool -import -keystore ${JAVA_HOME}/jre/lib/security/cacerts -noprompt -storepass changeit \
    -file /etc/ssl/certs/ca-cert-COMODO_ECC_Certification_Authority.pem -alias "comodo-ecc-certification-authority" -trustcacerts && \
    keytool -import -keystore ${JAVA_HOME}/jre/lib/security/cacerts -noprompt -storepass changeit \
    -file /etc/ssl/certs/ca-cert-DigiCert_Global_Root_CA.pem -alias "digicert-global-root-ca" -trustcacerts

WORKDIR ${DOCKER_ANDROID_HOME}

# Gradle installation.
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle-${GRADLE_VERSION}-bin.zip && \
    rm gradle-${GRADLE_VERSION}-bin.zip

# Android SDK Tools installation.
RUN wget http://dl.google.com/android/android-sdk_r${ANDROID_SDK_TOOLS_VERSION}-linux.tgz && \
    tar xzvf android-sdk_r${ANDROID_SDK_TOOLS_VERSION}-linux.tgz && \
    rm android-sdk_r${ANDROID_SDK_TOOLS_VERSION}-linux.tgz

ENV PATH=$PATH:${JAVA_HOME}/bin:${GRADLE_HOME}/bin:${ANDROID_SDK_TOOLS_HOME}/tools:${ANDROID_SDK_TOOLS_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}

# Android SDK packages installation.
RUN echo "y" | android update sdk --no-ui --filter platform-tools,build-tools-${ANDROID_BUILD_TOOLS_VERSION},android-${ANDROID_API_LEVEL}
