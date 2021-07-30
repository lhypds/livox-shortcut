#!/bin/bash

# set params
# example: bash '/home/liu/Desktop/livox-shortcut/auto-calibration.sh' -i="test1" -d="20210721" -b=""
EXPERIMENT="test4"
DATE="20210729"
BASE="3JEDHC900100491"
DEVICES="/home/liu/Desktop/livox-shortcut/auto-calibration/target-devices.txt"
RESULT="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-calib-result.txt"

for i in "$@"
do
case $i in
  -i=*|--experiment=*)
  EXPERIMENT="${i#*=}"
  ;;
  -d=*|--date=*)
  DATE="${i#*=}"
  ;;
  -b=*|--base=*)
  BASE="${i#*=}"
  ;;
esac
done

bash '/home/liu/Desktop/livox-shortcut/ros-driver-lvx-to-rosbag/livox-ros-driver-launch-lvx-to-rosbag-multi-topic.sh' -i="/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.lvx"
echo "LVX convert to ROSBAG file complete"

# loop for one calibration
NOW=$(date +"%T")
echo "start auto calibration...(start = $NOW)" | tee -a "$RESULT"

while IFS= read -r line
do
  bash '/home/liu/Desktop/livox-shortcut/ros-rosbag-to-pcd/ros-bag-to-pcd-for-auto-calibration.sh' -i="/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" -b="${BASE}" -t="$line"

  # rename all files in Base_LiDAR_Frames
  echo "renaming files..."
  cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Base_LiDAR_Frames
  i=100000
  for file in $(find * -name '*.pcd' | sort)
  do
    mv $file "$i.pcd"
    i=$((i+1))
  done

  # rename all files in Target-LiDAR-Frames
  cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Target-LiDAR-Frames
  i=100000
  for file in $(find * -name '*.pcd' | sort)
  do
    mv $file "$i.pcd"
    i=$((i+1))
  done
  echo "renaming complete"

  # real calibration execution
  NOW=$(date +"%T")
  echo "calibration for base = ${BASE} target = $line...(start = $NOW)" | tee -a "$RESULT"
  cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build
  bash run.sh -r="$RESULT"
  NOW=$(date +"%T")
  echo "calibration complete for $line(finsh = $NOW)" | tee -a "$RESULT"

  # copy mapping result to Experiment folder
  cp "/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/H-LiDAR-Map-data/H_LiDAR_Map.pcd" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}-mapping.pcd"
done < "$DEVICES"

NOW=$(date +"%T")
echo "All calibration complete(finish = $NOW)" | tee -a "$RESULT"
xdg-open "$RESULT"
