#!/system/bin/sh

product=`getprop ro.build.product`
# grep the modem partition for baseband version and set it
case "$product" in
        "ls980" | "vs980")
        setprop gsm.version.baseband `strings /firmware/image/modem.b18 | grep "^MPSS.DI" | head -1`
        ;;
        "d800" | "d801" | "d802" | "d803" | "f320" | "l01f")
        setprop gsm.version.baseband `strings /firmware/image/modem.b21 | grep "^M8974A-" | head -1`
        ;;
esac

bootloader=`strings /dev/block/platform/msm_sdcc.1/by-name/aboot | grep "mdss_mdp.panel="`
# Check aboot version using mdss_mdp.panel string
case "$bootloader" in
        "mdss_mdp.panel=")
        setprop ro.bootloader rev_b
        ;;
        *)
        setprop ro.bootloader rev_a
        ;;
esac
