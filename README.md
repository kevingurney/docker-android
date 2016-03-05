# docker-android

A Docker image for Android development.

## Build Arguments

The following build arguments can be used to customize the Android development environment through the use of the `--build-arg` flag for the `docker build` command.

* `ANDROID_API_LEVELS`
    * Comma separated list of Android API levels, with the general form: `android-<api-level>,...,android-<api-level>`
    * Default: `android-19,android-21,android-22,android-23`
* `ANDROID_SDK_TOOLS_VERSION`
    * Android SDK Tools version
    * Default: `24.4.1`
* `ANDROID_BUILD_TOOLS_VERSION`
    * Android Build Tools version
    * Default: `23.0.2`
* `GRADLE_VERSION`
    * Gradle version
    * Default: `2.11`
* `JAVA_VERSION`
    * Java version
    * Default: `7`
    * **Note**: Uses OpenJDK

## Environment Variables

* `JAVA_HOME`
    * `/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64`
* `GRADLE_HOME`
    * `/opt/gradle-${GRADLE_VERSION}`
* `ANDROID_HOME`
    * `/opt/android-sdk-linux`

## Permissions

By default, any command run by a `docker-android` container will run as user `default`, which does not have super user permissions.

If super user permission are required, the `--user` flag can be passed to the `docker run` command with value `root`.

## Gradle Wrapper

To prevent the Gradle Wrapper script from repeatedly downloading a new Gradle distribution, you can create a directory on your host machine to store the downloaded Gradle distribution and bind-mount it using the `--volume` flag to `/home/default/.gradle` (if running commands as user `default` inside of the container) or `/root/.gradle` (if running commands as user `root` inside of the container). For example,

`--volume <host-gradle-directory>:/home/default/.gradle`

## Connecting to an Android Device via USB

In order to interact with a physical Android device connected to a host machine via USB (e.g. using the Android Debug Bridge (adb)), you can share `/dev/bus/usb` with a `docker-android` container by passing the `--device` flag to the `docker run` command.
