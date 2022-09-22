# pm_opencv_plugin

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

This branch not use tesseract4Android, because it cannot use in methodchannel 

To add tesseract into the project as native , flow the steps below:

1) Download and install the ndk from here https://developer.android.com/tools/sdk/ndk/index.html. I had some trouble with its path in following steps so i put it in “C:\”.

2) Add that path to environment variables of the system (eg: “C:\android_ndk_r10d”) and then reboot so your machine can find it.

3) Download “tess-two-master” from here https://github.com/rmtheis/tess-two, extract it (for example in “C:\”) and rename it in “tess”.

4) Open “tess” folder and then open “tess-two” folder. Click on a blank space while pressing the shift button and select “Open command window here”.

5) Write “ndk-build” and wait until it completes (about 20min).

Now the generated put in the /Usr/minganpeng/devplugin/tess/tess-two/libs.
copy to the android/jnilibs directory to link with other native source.

