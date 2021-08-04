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

/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build/./mapping
/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build/./calibration
/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build/./fitline | tee -a "$RESULT" "$LOG"
