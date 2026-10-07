#!/system/bin/sh
# Moto G20 (java): persistent kernel+recovery log capture.
# The kernel keeps running while the recovery UI appears stuck; /proc/kmsg
# streams everything init/ueventd/kernel emit, and /cache survives recovery
# reboots (unlike ramoops after a cold power-off). Written by the su-seclabel
# service so no extra SELinux allows are needed.
KLOG=/cache/recovery-klog.txt
PROPS=/cache/recovery-props.txt
: > "$KLOG" 2>/dev/null
cat /proc/kmsg >> "$KLOG" 2>/dev/null &
KMSG_PID=$!
# mirror to /tmp so the adb shell can read it (/cache is SELinux-blocked for shell)
sync_mirror() { cp "$KLOG" /tmp/klogdump.txt 2>/dev/null; }
sync_mirror
sleep 2
getprop >> "$PROPS" 2>/dev/null
logcat -d >> "$KLOG" 2>/dev/null
# keep streaming the kernel log for the life of the recovery session
sync_mirror
(while true; do sleep 5; sync_mirror; done) &
wait $KMSG_PID
