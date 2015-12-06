#!/system/bin/sh

network=`ro.telephony.default_network`
baseband=`getprop gsm.version.baseband`

# Check if it has a CDMA or GSM radio.
if [ "$network" == "10" ]; then
        modem=`strings /firmware/image/modem.b18 | grep "^MPSS.DI" | head -1`
else
        modem=`strings /firmware/image/modem.b21 | grep "^M8974A-" | head -1`
fi

# Set baseband version by grepping it from modem partition.
if [ "$baseband" != "$modem" ]; then
        setprop gsm.version.baseband "$modem"
fi
