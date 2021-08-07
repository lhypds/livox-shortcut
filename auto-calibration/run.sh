#!/bin/bash 

for i in "$@"
do
case $i in
  -r=*|--result=*)
  RESULT="${i#*=}"
  ;;
  -l=*|--log=*)
  LOG="${i#*=}"
  ;;
esac
done

cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build
/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build/./mapping
/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build/./calibration
/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build/./fitline | tee "$RESULT"
cat "$RESULT" | tee -a "$LOG"
