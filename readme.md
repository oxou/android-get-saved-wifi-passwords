# Android - Get Saved Wi-Fi Passwords

## Introduction

This is a Bash script to list the saved passwords on an Android device.

I do not guarantee this script will work on every device, and it probably
won't.

It requires root access to the phone, if you don't have that then don't
bother trying.

## Ways to do it without root?

If you're unable to root your device for whatever reasons like locked
bootloader, etc.

There have been privilege escalation exploits in the past where a non-root
user could read or write to system-protected files on an Android device.

I will not go into more details regarding this topic, and I won't be
responsible if you brick your device and lose warranty in the process.

Your device is also your sole responsibility, and no bodies else.

## How to use it?

To use the script, you need Android Debug Bridge (ADB) installed on your
operating system, search online "How to enable developer options" and how
to get ADB Shell working.

Once you've got an ADB shell working you are ready to extract the saved
Wi-Fi passwords.

Run the commands:

```
su
cd /data/local/tmp
wget {url_here} -O out
chmod +x out
./out
```
