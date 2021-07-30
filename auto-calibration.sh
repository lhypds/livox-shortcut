#!/bin/bash
START=$(date +"%T")

# Params
# Example: bash '/home/liu/Desktop/livox-shortcut/auto-calibration.sh' -i="test1" -d="20210721" -b=""
EXPERIMENT="test1"
DATE="20210721"
BASE="3JEDHC900100491"
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
echo "LVX convert to ROSBAG file complete..."

# Loop for one calibration
DEVICES="/home/liu/Desktop/livox-shortcut/auto-calibration/target-devices.txt"
echo "start auto calibration..." | tee -a '/home/liu/Desktop/livox-shortcut/auto-calibration-data/calib_result.txt'
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
  echo "complete..."

  # real calibration execution
  echo "calibration for base = ${BASE} target = $line..." | tee -a '/home/liu/Desktop/livox-shortcut/auto-calibration-data/calib_result.txt'
  cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build
  bash run.sh
  echo "calibration complete for $line!"
done < "$DEVICES"

FINISH=$(date +"%T")
echo "All calibration complete, time = $FINISH (start = $START)" | tee -a '/home/liu/Desktop/livox-shortcut/auto-calibration-data/calib_result.txt'
xdg-open '/home/liu/Desktop/livox-shortcut/auto-calibration-data/calib_result.txt'
