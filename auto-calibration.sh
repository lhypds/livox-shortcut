#!/bin/bash

# rename all files in Base_LiDAR_Frames
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

cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build
bash run.sh
