# Copyright (C) 2023 Nurudin Imsirovic <github.com/oxou>
#
# List saved Wi-Fi passwords on a rooted Android device
#
# Prerequisites:
# - cat
# - cut
# - grep
# - head
# - sed
# - stat
# - su
# - which
#
# Created: 2023-07-16 01:43 PM
# Updated: 2023-07-16 05:59 PM

# Detect that the script is being ran in Termux
IS_TERMUX=0
REALECHO=
RETVAL=
PW_COUNT=0

if [ ! "$TERMUX_APP_ID" = "" ] || [ ! "$TERMUX_VERSION" = "" ]; then
    IS_TERMUX=1
fi

# Get direct path to the 'echo' command
if [ "$IS_TERMUX" = "1" ]; then
    if [ ! -f "/data/data/com.termux/files/usr/bin/echo" ]; then
        # If for whatever case echo doesn't exist on this Termux
        # instance, we'll fallback to /usr/bin/echo and pray that
        # it works.
        if [ -f "/system/bin/echo" ]; then
            REALECHO="/system/bin/echo"
        elif [ ! -f "/usr/bin/echo" ]; then
            echo "============= FATAL ERROR ============="
            echo "Could not find the path to the 'echo' binary"
            echo "Cannot continue running the tool, either"
            echo "manually modify the file or make sure your"
            echo "Termux instance is not broken"
            exit 32
        else
            REALECHO="/usr/bin/echo"
        fi
    else
        REALECHO="/data/data/com.termux/files/usr/bin/echo"
    fi
else
    if [ -f "/system/bin/echo" ]; then
        REALECHO="/system/bin/echo"
    elif [ ! -f "/usr/bin/echo" ]; then
        echo "============= FATAL ERROR ============="
        echo "Could not find the path to the 'echo' binary"
        echo "Cannot continue running the tool, make sure"
        echo "your system is not broken"
        exit 64
    else
        REALECHO=/usr/bin/echo
    fi
fi

$REALECHO -e "\x1B[0m================================================================================"
$REALECHO "= Copyright (C) 2023 Nurudin Imsirovic <github.com/oxou>                       ="
$REALECHO "= List saved Wi-Fi passwords on a rooted Android Device                        ="
$REALECHO "= GitHub Repository: https://github.com/oxou/android-get-saved-wi-fi-passwords ="
$REALECHO "=                                                          Version: 2023-07-16 ="
$REALECHO -e "\x1B[0m================================================================================"

msg_error() {
    $REALECHO -e "\x1B[31mError:\x1B[0m $*"
}

msg_info() {
    $REALECHO -e "\x1B[32mInfo:\x1B[0m $*"
}

msg_note() {
    $REALECHO -e "\x1B[33mNote:\x1B[0m $*"
}

odd_error() {
    msg_error "This is an odd error, is the system Android? If so it may be broken or incompatible"
}

# Exit because user is not root
if [ ! "$(id -u)" = "0" ]; then
    msg_error "This tool requires root privileges"
    msg_info "Use these commands"
    msg_info "  Termux:"
    msg_info "    sudo -E sh $0"
    msg_info ""
    msg_info "  ADB Shell:"
    msg_info "    su -m -c sh $0"
    exit 1
fi

# Notify the user they're running inside Termux
if [ "$IS_TERMUX" = "1" ]; then
    msg_note "Running inside a Termux environment"
fi

# If running on Termux we make sure the 'which'
# command exists.

if [ "$IS_TERMUX" = "1" ]; then
    if [ ! -f "/data/data/com.termux/files/usr/bin/which" ]; then
        msg_error "'which' not found (running in Termux)"
        msg_info "To install 'which' run: pkg install which -y"
        exit 2
    fi
fi

# Ensure all system commands exist

which cat >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "'cat' not found"
    exit 4
fi

# -----------------------------

which cut >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "'cut' not found"
    exit 8
fi

# -----------------------------

which grep >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "'grep' not found"
    exit 16
fi

# -----------------------------

which head >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "'head' not found"
    exit 32
fi

# -----------------------------

which sed >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "'sed' not found"
    exit 8
fi

# -----------------------------

which stat >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "'stat' not found"
    exit 16
fi

# -----------------------------

which su >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "'su' not found"
    msg_error "Is your device rooted?"
    exit 128
fi

msg_info "All system commands available"
msg_info "Searching for the 'WifiConfigStore.xml' file ..."

if [ ! -d "/data" ]; then
    msg_error "'/data' not found"
    odd_error
    exit 256
fi

if [ ! -d "/data/misc" ]; then
    msg_error "'/data/misc' not found"
    odd_error
    exit 512
fi

if [ ! -d "/data/misc/apexdata" ]; then
    msg_error "'/data/misc/apexdata' not found"
    msg_error "Can't retrieve Wi-Fi information"
    exit 1024
fi

if [ ! -d "/data/misc/apexdata/com.android.wifi" ]; then
    msg_error "'/data/misc/apexdata/com.android.wifi' not found"
    msg_error "Can't retrieve Wi-Fi information"
    exit 2048
fi

if [ ! -f "/data/misc/apexdata/com.android.wifi/WifiConfigStore.xml" ]; then
    msg_error "'WifiConfigStore.xml' not found"
    msg_error "Can't retrieve Wi-Fi information"
    msg_error "Without this file, nothing more can be done."
    exit 4096
fi

msg_info "'WifiConfigStore.xml' found !"
msg_info "Checking file size..."

FILEPATH="/data/misc/apexdata/com.android.wifi/WifiConfigStore.xml"
FILESIZE=$(stat "$FILEPATH" -c "%s")

if [ "$FILESIZE" = "0" ]; then
    msg_error "The file is empty."
    msg_error "Can't retrieve Wi-Fi information"
    exit 8192
fi

msg_info "'WifiConfigStore.xml' size is $FILESIZE"
msg_info "Verifying file contents..."

FILEDATA=$(cat "$FILEPATH")
FILEHEAD=$(cat "$FILEPATH" | head -n 1 | cut -c1-5)

if [ ! "$FILEHEAD" = "<?xml" ]; then
    msg_error "File does not appear to be XML."
    msg_error "Nothing more can be done."
    exit 16384
else
    msg_info "Verifying file contents... Found XML header"
fi

echo "$FILEDATA" | grep -i "<WifiConfiguration>" >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "Could not find 'WifiConfiguration' inside the XML"
    msg_error "Nothing more can be done."
    exit 32768
fi

msg_info "Verifying file contents... Found <WifiConfiguration>"

echo "$FILEDATA" | grep -i "name=\"ConfigKey\"" >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "Could not find 'name=\"ConfigKey\"' inside the XML"
    msg_error "Nothing more can be done."
    exit 65536
fi

msg_info "Verifying file contents... Found <string name=\"ConfigKey\""

echo "$FILEDATA" | grep -i "name=\"PreSharedKey\"" >/dev/null 2>&1

if [ ! "$?" = "0" ]; then
    msg_error "Could not find 'name=\"PreSharedKey\"' inside the XML"
    msg_error "Nothing more can be done."
    exit 131072
fi

msg_info "Verifying file contents... Found <string name=\"PreSharedKey\""
msg_info "Verification finished successfully"
msg_info "Parsing the file and writing the results into the buffer ..."

# Here we store the final output once we have iterated through the file.
# Note: in the SSID and KEY we store the Wi-Fi information, it is discarded
#       if no KEY is found, this KEY is cleared whenever a line starting with
#       "<WifiConfiguration>" is matched.
BUFFER_SSID=""
BUFFER_KEY=""
BUFFER=""

IFSBAK=$IFS
IFS=$'\n'

# Replace CRLF (\r\n) with LF (\n) (if any)
FILEDATA=$(echo "$FILEDATA" | sed -e "s/\\r//g")

# Parser functions for extracting the data and writing it out into
# the BUFFER variable.
verify_wifi_buffers() {
    data=$1

    echo $data | grep -i "^<WifiConfiguration" >/dev/null 2>&1

    if [ ! "$BUFFER_SSID" = "" ] && [ ! "$BUFFER_KEY" = "" ]; then
        BUFFER="$BUFFER\n\x1B[33m===============================\x1B[0m\n\n  "
        BUFFER="$BUFFER\x1B[32mSSID\x1B[0m: $BUFFER_SSID\n"
        BUFFER="$BUFFER\n  \x1B[32mKEY:\x1B[0m  $part\n"
        BUFFER_SSID=""
        BUFFER_KEY=""
    fi
}

remove_quot() {
    data=$1

    # Remove prefix
    data=$(echo $data | sed -e "s/^&quot;//g")

    # Remove suffix
    data=$(echo $data | sed -e "s/\&quot;$//g")

    RETVAL=$data
}

parse_ssid() {
    # Clear previous Wi-Fi KEY (if any)
    if [ ! "$BUFFER_KEY" = "" ]; then
        BUFFER_KEY=""
    fi

    # Find the name identifier
    echo $1 | grep -i "name=\"SSID\"" >/dev/null 2>&1

    # Not an SSID, skip
    if [ ! "$?" = "0" ]; then
        RETVAL=0
        return
    fi

    # Extract the part where the SSID begins
    part=$(echo $1 | awk -F '>' '{print $2}')

    # Find </string
    echo $part | grep -i "</string" >/dev/null 2>&1

    if [ ! "$?" = "0" ]; then
        return
    fi

    part=$(echo $part | awk -F "</string" '{print $1}')

    remove_quot $part
    part=$RETVAL

    BUFFER_SSID=$part
}

parse_presharedkey() {
    # Find the name identifier
    echo $1 | grep -i "name=\"PreSharedKey\"" >/dev/null 2>&1

    # Not a key, skip
    if [ ! "$?" = "0" ]; then
        RETVAL=0
        return
    fi

    # Extract the part where the key begings
    part=$(echo $1 | awk -F '>' '{print $2}')

    # Find </string
    echo $part | grep -i "</string" >/dev/null 2>&1

    if [ ! "$?" = "0" ]; then
        return
    fi

    part=$(echo $part | awk -F "</string" '{print $1}')

    remove_quot $part
    part=$RETVAL

    # Increment password count
    PW_COUNT=$(($PW_COUNT+1))

    BUFFER_KEY=$part
}

# Loop through each line and extract data based on a fast approach using
# a heuristics (nearest-neighbor) approach
for line in $FILEDATA
do
    # Skip empty lines
    if [ "$line" = "" ]; then
        continue
    fi

    # Parse and extract data
    parse_ssid $line

    #if [ "$RETVAL" = "0" ]; then
    #    continue
    #fi

    parse_presharedkey $line

    #if [ "$RETVAL" = "0" ]; then
    #    continue
    #fi

    verify_wifi_buffers $line
done

msg_info "Parsing finished."

if [ "$PW_COUNT" = "0" ]; then
    msg_error "No saved passwords were found."
    msg_error "Nothing more can be done."
    exit 262144
fi

if [ "$PW_COUNT" = "1" ]; then
    msg_info "Found $PW_COUNT password"
else
    msg_info "Found $PW_COUNT passwords"
fi

BUFFER="$BUFFER\n\x1B[33m===============================\x1B[0m\n"
echo $BUFFER
exit 0
