# Jenkins-Flutter

> Containerized Jenkins resource pipeline to run Flutter Driver tests on an auto discoverable device farm.

This repository contains a recipe to build a Docker container containing Jenkins and Flutter / Android build tools
which might be useful to perform some basic in house integration tests of Flutter apps.

## Why should I do it?

You shouldn't. That's it.
But if you happen to have a couple devices lurking around and you feel bad about throwing them as garbage because 
you deeply feel they can still have some usefulness, you have some integration test knowledge and you consider it
might be worth testing this idea and having some fun, then you have a couple good reasons to try that out.

## What do I need?
Docker. It works best on Linux, so it's advisable to host that container on a Linux machine.
You may find issues running Docker for the first time. In my case it was due permissions. 
I guess this is actually applicable to all Linux distros:
- create the docker group if it doesn't exist: `sudo groupadd docker`
- add your user to that group: `sudo usermod -aG docker $USER`
- login to the new group with: `newgrp docker` 
- `sudo systemctl start docker`


## Why bundling everything on a single container instead of creating multiple Flutter agents to be orchestrated by Jenkins?
Because I made this to run on my laptop, which is not a full fledged build server. One can improve over this idea and split the container.
I believe it will be an elegant solution, will leverage true parallelism, but it will cost a lot to raise a bunch of containers, one per device.
It's up to you. To me it worked ok and I had some fun doing the way I did.

## How do I build this container
Glad you ask.
```
docker build -t jenkins-flutter .
```
Or a better name other than "jenkins-flutter", if you have one.

## How should I run this container?
Good question. It is a little bit evolving to lift it up:
```shell
docker run --publish 4444:4444 --publish 42000:42000 --publish 8080:8080 --mount type=bind,source="$(pwd)/example",target=/mnt,readonly -v /dev/bus/usb:/dev/bus/usb --privileged -v jenkins-data:/var/jenkins_home jenkins-flutter
```

In the command line above we publish some container ports:
- 8080: HTTP to access Jenkins website
- 4444: Chromedriver (I didn't experiment with it, but that's possible, I think)
- 42000: I forgot what was that. When I recover my memory I'll edit this.

Bind-mounting the example app source folder avoids the need to push to GitHub from the development machine and pulling from the container. Target could be
whatever mount point you wish to mount the source folder into the container. For me /mnt is good.
If we don't mount a jenkins-data volume, every time we ran the container it is like the first time, which means plugin installation every time. There will be no persistence by default.
And finally `/dev/bus/usb:/dev/bus/usb --privileged` to allow the container to access the USB ports, where the devices will stay connected.
Important: Do not run ADB on the host computer. Leave it to the container. 
If ADB is running, kill it: `adb kill-server`

## Be careful not to connect too many devices and overload your USB ports.
There are some USB hubs with external power supply. If you can buy one of those, it might be safer.
I tested this with 3 devices at maximum on a single hub. I don't know how many devices are needed to permanently damage a USB port, but I guess nobody really
wants to find it out.

## A short demo
I made the video in the link below to share the idea with class mates of the Software Engineering course.
Audio is in Portuguese, because that's our mother language.
I was not intending to publish that.
Maybe sometime I take another moment and record a proper demo in English.
[For now that's what we've got](https://youtu.be/uAcN9GsjdcQ)
