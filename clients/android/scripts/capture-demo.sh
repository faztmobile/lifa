#!/usr/bin/env bash
# Captures the demo journey screens from the installed app on a running emulator, with a clean demo-mode
# status bar. Usage: scripts/capture-demo.sh <apk> <out-dir>
set -euo pipefail
apk="$1"; out="$2"; mkdir -p "$out"
ids=(signup home will assets vault emergency checkin activation executor plans)

adb uninstall za.co.lifa >/dev/null 2>&1 || true
adb install -r "$apk"
adb shell settings put global sysui_demo_allowed 1
demo() { adb shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null; }
demo enter
demo clock -e hhmm 0941
demo battery -e level 100 -e plugged false
demo network -e wifi show -e level 4
demo network -e mobile show -e datatype none -e level 4
demo notifications -e visible false
adb shell cmd uimode night no

n=0
for id in "${ids[@]}"; do
  n=$((n + 1))
  adb shell am force-stop za.co.lifa
  adb shell am start -W -n za.co.lifa/.MainActivity --es lifa.demo "$id" >/dev/null
  sleep 3
  adb exec-out screencap -p > "$out/$(printf '%02d' "$n")-$id.png"
  echo "captured $id"
done
