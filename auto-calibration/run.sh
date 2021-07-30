#!/bin/bash 

for i in "$@"
do
case $i in
  -r=*|--result=*)
  RESULT="${i#*=}"
  ;;
esac
done

./mapping
./calibration
./fitline &>> "$RESULT"
