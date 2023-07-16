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
wget "https://raw.githubusercontent.com/oxou/android-get-saved-wifi-passwords/main/run.sh"
chmod +x run.sh
sh run.sh
```

You should get an output like this (if you have any passwords saved):

```
================================================================================
= Copyright (C) 2023 Nurudin Imsirovic <github.com/oxou>                       =
= List saved Wi-Fi passwords on a rooted Android Device                        =
= GitHub Repository: https://github.com/oxou/android-get-saved-wi-fi-passwords =
=                                                          Version: 2023-07-16 =
================================================================================
Info: All system commands available
Info: Searching for the 'WifiConfigStore.xml' file ...
Info: 'WifiConfigStore.xml' found !
Info: Checking file size...
Info: 'WifiConfigStore.xml' size is 29551
Info: Verifying file contents...
Info: Verifying file contents... Found XML header
Info: Verifying file contents... Found <WifiConfiguration>
Info: Verifying file contents... Found <string name="ConfigKey"
Info: Verifying file contents... Found <string name="PreSharedKey"
Info: Verification finished successfully
Info: Parsing the file and writing the results into the buffer ...
Info: Parsing finished.
Info: Found 5 passwords

===============================

  SSID: [REDACTED]

  KEY:  [REDACTED]

===============================

  SSID: [REDACTED]

  KEY:  [REDACTED]

===============================

...
```
