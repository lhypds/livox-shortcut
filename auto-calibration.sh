#!/bin/bash

# no need to remove files, as it will all auto cleanup
# if the first result exist, it will use it to create second result
# if the first result and second result exist, it will mv the second to first and re-create the second
# the target device info it put into the EXPREIMENT folder

# set params
# example: bash '/home/liu/Desktop/livox-shortcut/auto-calibration.sh' -i="test1" -d="20210721" -b=""
EXPERIMENT="test1"
DATE="20210805"
BASE="3JEDHB300100641"
DEVICES="/home/liu/Desktop/Experiment_$DATE/target-devices.txt"
LOG="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-calib-log.txt"
THIS_RESULT="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-calib-result.xml"
FIRST_RESULT="/home/liu/Desktop/Experiment_$DATE/first-result.xml"
SECOND_RESULT="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-second-result.xml"
USE_REMOTE_MACHINE=false
REMOTE_IP="192.168.17.70"
NOW=$(date +"%T")
USE_LVX=false
BYPASS_ROSBAG=false

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

# send to remote machine to accelerate
if $USE_REMOTE_MACHINE && [ $(hostname -I) != $REMOTE_IP ]; then
  echo "Sending LVX to remote..."
  tmux new-session -d -s "send-file"
  gnome-terminal -x bash -c "tmux attach -t "send-file"; exec bash && exit"
  tmux send-key -t "send-file" 'scp "/home/liu/Desktop/Experiment_'${DATE}/${EXPERIMENT}'.lvx" liu@'$REMOTE_IP':/home/liu/Desktop/Experiment_'${DATE}/${EXPERIMENT}'.lvx' Enter
fi

# convert to rosbag
if $USE_LVX; then
  echo "Converting LVX to ROSBAG..."
  rm "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag"
  tmux new-session -d -s "lvx2bag"
  sleep 1

  # show execute
  gnome-terminal -x bash -c "cd ~/Videos && tmux attach -t "lvx2bag"; exec bash && exit"

  # execute LVX to rosbag
  tmux send-key -t "lvx2bag" 'bash '/home/liu/Desktop/livox-shortcut/ros-driver-lvx-to-rosbag/livox-ros-driver-launch-lvx-to-rosbag-multi-topic.sh' -i="/home/liu/Desktop/Experiment_'${DATE}/${EXPERIMENT}'.lvx"' Enter
  sleep 10

  # kill the show execute
  tmux send-key -t "lvx2bag" C-c
  tmux send-key -t "lvx2bag" 'exit' Enter
  sleep 2
  xdotool search "~/Videos" windowclose
  echo "LVX convert to ROSBAG file complete"
  mv "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.lvx" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.lvx-$NOW"
fi

# show rosbag info
rosbag info "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" | tee -a "$LOG"

# loop for one calibration
echo "start auto calibration...(start = $NOW)" | tee -a "$LOG"

# cleanup previous result
if test -f "$THIS_RESULT"; then
  rm "$THIS_RESULT"
fi

# run calibration base on previous result
if test -f "$FIRST_RESULT"; then
  # replace the first result with the previous second result
  if test -f "$SECOND_RESULT"; then
    mv "$FIRST_RESULT" "$FIRST_RESULT-$NOW"

    # re-create second result
    cp "$SECOND_RESULT" "$SECOND_RESULT-$NOW"
    mv "$SECOND_RESULT" "$FIRST_RESULT"
  fi

  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$SECOND_RESULT"
  echo "<Livox>" >> "$SECOND_RESULT"
fi

# create current calibration result
if test -f "$THIS_RESULT"; then
  rm "$THIS_RESULT"
fi
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$THIS_RESULT"
echo "<Livox>" >> "$THIS_RESULT"

while IFS= read -r line
do
  if $BYPASS_ROSBAG; then
    echo "Bypass rosbag..."
  fi

  if ! $BYPASS_ROSBAG; then
    echo "Rosbag topic separating..."
    bash '/home/liu/Desktop/livox-shortcut/ros-rosbag-to-pcd/ros-bag-to-pcd-for-auto-calibration.sh' -i="/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" -b="${BASE}" -t="$line"
    echo "Rosbag topic separating complete"

    # backup rosbag
    echo "Rosbag backup..."
    cp "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag-$NOW"

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
  fi

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

echo "mission complete!" | espeak
# show calibration log
#xdg-open "$LOG"
