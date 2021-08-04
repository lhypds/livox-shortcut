#!/bin/bash

# set params
# example: bash '/home/liu/Desktop/livox-shortcut/auto-calibration.sh' -i="test1" -d="20210721" -b=""
EXPERIMENT="test1"
DATE="20210804"
BASE="3JEDHC900100491"
DEVICES="/home/liu/Desktop/livox-shortcut/auto-calibration/target-devices.txt"
LOG="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-calib-log.txt"
THIS_RESULT="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-calib-result.xml"
FIRST_RESULT="/home/liu/Desktop/Experiment_$DATE/first-result.xml"
SECOND_RESULT="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-second-result.xml"

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

echo "Converting LVX to ROSBAG..."
tmux new-session -d -s "lvx2bag"
sleep 1

# show execute
gnome-terminal -x bash -c "tmux attach -t "lvx2bag"; exec bash && exit"

# execute LVX to rosbag
tmux send-key -t "lvx2bag" 'bash '/home/liu/Desktop/livox-shortcut/ros-driver-lvx-to-rosbag/livox-ros-driver-launch-lvx-to-rosbag-multi-topic.sh' -i="/home/liu/Desktop/Experiment_'${DATE}/${EXPERIMENT}'.lvx"' Enter
sleep 8

# kill the show execute
tmux send-key -t "lvx2bag" C-c
tmux send-key -t "lvx2bag" 'exit' Enter
pkill gnome-terminal
echo "LVX convert to ROSBAG file complete"
rm "$LOG"
rosbag info "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" | tee -a "$LOG"

# loop for one calibration
NOW=$(date +"%T")
echo "start auto calibration...(start = $NOW)" | tee -a "$LOG"
rm "$THIS_RESULT"
rm "$SECOND_RESULT"
if test -f "$FIRST_RESULT"; then
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$SECOND_RESULT"
  echo "<Livox>" >> "$SECOND_RESULT"
fi
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$THIS_RESULT"
echo "<Livox>" >> "$THIS_RESULT"

while IFS= read -r line
do
  echo "Rosbag topic separating..."
  bash '/home/liu/Desktop/livox-shortcut/ros-rosbag-to-pcd/ros-bag-to-pcd-for-auto-calibration.sh' -i="/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" -b="${BASE}" -t="$line"
  echo "Rosbag topic separating complete"

  # rename all files in Base_LiDAR_Frames
  echo "Renaming files..."
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
  echo "Renaming complete"

  # real calibration execution
  NOW=$(date +"%T")
  echo "calibration for base = ${BASE} target = $line...(start = $NOW)" | tee -a "$LOG"
  cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/build
  bash /home/liu/Desktop/livox-shortcut/auto-calibration/run.sh -r="/home/liu/Desktop/out/temp.txt" -l="$LOG"

  # create the result
  if test -f "$FIRST_RESULT"; then
    python3 '/home/liu/Desktop/livox-shortcut/auto-calibration/calculate-result.py' $line $FIRST_RESULT >> "$SECOND_RESULT"
  fi
  python3 '/home/liu/Desktop/livox-shortcut/auto-calibration/generate-result-string.py' $line >> "$THIS_RESULT"
  rm "/home/liu/Desktop/out/temp.txt"

  NOW=$(date +"%T")
  echo "calibration complete for $line(finsh = $NOW)" | tee -a "$LOG"

  # copy mapping result to Experiment folder
  cp "/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/H-LiDAR-Map-data/H_LiDAR_Map.pcd" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}-mapping.pcd"
done < "$DEVICES"

NOW=$(date +"%T")
echo "All calibration complete(finish = $NOW)" | tee -a "$LOG"

if test -f "$FIRST_RESULT"; then
  echo "</Livox>" >> "$SECOND_RESULT"
fi
echo "</Livox>" >> "$THIS_RESULT"

# show calibration log
#xdg-open "$LOG"
