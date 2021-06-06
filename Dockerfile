FROM jenkins/jenkins:lts-jdk11

ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"
ENV ANDROID_VERSION="29"
ENV ANDROID_BUILD_TOOLS_VERSION="29.0.3"
ENV ANDROID_ARCHITECTURE="x86_64"
ENV ANDROID_SDK_ROOT="/opt/android"
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="2.0.4"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
ENV FLUTTER_HOME="/opt/flutter"
ENV FLUTTER_WEB_PORT="4444"
ENV FLUTTER_DEBUG_PORT="42000"
ENV FLUTTER_EMULATOR_NAME="flutter_emulator"
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$FLUTTER_HOME/bin:$PATH"


USER root
RUN apt-get update && apt-get install -y --no-install-recommends bash curl file git unzip xz-utils zip \
    libglu1-mesa sed ssh xauth x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx \
    chromium-driver && rm -rf /var/lib/{apt,dpkg,cache,log}


# android sdk
RUN mkdir -p $ANDROID_SDK_ROOT \
        && mkdir -p /home/$USER/.android \
        && touch /home/$USER/.android/repositories.cfg \
        && curl -o android_tools.zip $ANDROID_TOOLS_URL \
        && unzip -qq -d "$ANDROID_SDK_ROOT" android_tools.zip \
        && rm android_tools.zip \
        && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/tools \
        && mv $ANDROID_SDK_ROOT/cmdline-tools/bin $ANDROID_SDK_ROOT/cmdline-tools/tools \
        && mv $ANDROID_SDK_ROOT/cmdline-tools/lib $ANDROID_SDK_ROOT/cmdline-tools/tools \
        && yes "y" | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
        && yes "y" | sdkmanager "platforms;android-$ANDROID_VERSION" \
        && yes "y" | sdkmanager "platform-tools" \
        && yes "y" | sdkmanager "emulator" \
        && yes "y" | sdkmanager "system-images;android-$ANDROID_VERSION;google_apis_playstore;$ANDROID_ARCHITECTURE"

# flutter
RUN curl -o flutter.tar.xz $FLUTTER_URL \
    && mkdir -p $FLUTTER_HOME \
    && tar xf flutter.tar.xz -C /opt \
    && rm flutter.tar.xz \
    && flutter config --no-analytics \
    && flutter precache \
    && yes "y" | flutter doctor --android-licenses \
    && flutter doctor \
    && flutter emulators --create \
    && flutter update-packages

RUN chown -R jenkins:jenkins /opt && chmod -R g+w /opt
USER jenkins:jenkins
