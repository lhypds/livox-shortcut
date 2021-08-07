#!/bin/bash 

for i in "$@"
do
case $i in
  -r=*|--result=*)
  RESULT="${i#*=}"
  ;;
  -p=*|--parallelinstance=*)
  INSTANCE="${i#*=}"
  ;;
esac
done

cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration_parallel/${INSTANCE}/build
/home/liu/livox/github-livox-sdk/Livox_automatic_calibration_parallel/${INSTANCE}/build/./mapping
/home/liu/livox/github-livox-sdk/Livox_automatic_calibration_parallel/${INSTANCE}/build/./calibration
/home/liu/livox/github-livox-sdk/Livox_automatic_calibration_parallel/${INSTANCE}/build/./fitline | tee "${RESULT}"

echo "Instance $INSTANCE compelte, press Enter to exit"
read key
exit
