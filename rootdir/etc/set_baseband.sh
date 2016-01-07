#!/system/bin/sh

product=`getprop ro.build.product`
baseband=`getprop gsm.version.baseband`

while true; do
    # grep the modem partition for baseband version and set it
    case "$product" in
        "ls980" | "vs980")
        setprop gsm.version.baseband `strings /firmware/image/modem.b18 | grep "^MPSS.DI" | head -1`
        ;;
        "d800" | "d801" | "d802" | "d803" | "f320" | "l01f")
        setprop gsm.version.baseband `strings /firmware/image/modem.b21 | grep "^M8974A-" | head -1`
        ;;
    esac

    sleep 8
    # Check if baseband is set and then exit
    if [ "$baseband" != "" ]; then
        break
    fi
done