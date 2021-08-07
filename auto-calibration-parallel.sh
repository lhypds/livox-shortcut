#!/bin/bash

# no need to remove files, as it will all auto cleanup
# if the first result exist, it will use it to create second result
# if the first result and second result exist, it will mv the second to first and re-create the second
# the target device info it put into the EXPREIMENT folder
USE_LVX=false
USE_ROSBAG=true

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

NOW=$(date +"%T")

# set params
# example: bash '/home/liu/Desktop/livox-shortcut/auto-calibration.sh' -i="test1" -d="20210721" -b=""
EXPERIMENT="test1"
DATE="20210805"
BASE="3JEDHB300100641"
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

DEVICES="/home/liu/Desktop/Experiment_$DATE/target-devices.txt"
LOG="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT.log"

# second result = first result - this result
THIS_RESULT="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-this-result.xml"
FIRST_RESULT="/home/liu/Desktop/Experiment_$DATE/first-result.xml"
SECOND_RESULT="/home/liu/Desktop/Experiment_$DATE/$EXPERIMENT-second-result.xml"

# remote machine
REMOTE_IP="192.168.17.70"

# 1. convert lvx to rosbag
if $USE_LVX; then
  if ! test -f "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.lvx"; then
    echo -e "${RED}LVX file not exist, record LVX or disbale USE_LVX${NC}"
    exit
  fi

  echo "Converting LVX to ROSBAG..."
  if test -f "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag"; then
    mv "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag-$NOW"
  fi
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
  echo -e "${GREEN}LVX convert to ROSBAG file complete${NC}"

  # backup the LVX file
  mv "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.lvx" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.lvx-$NOW"
fi

# 2. convert rosbag to pcd (base and target folder)
if $USE_ROSBAG; then
  if ! test -f "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag"; then
    echo -e "${RED}ROSBAG file not exist, record ROSBAG or convert from LVX or disbale USE_ROSBAG${NC}"
    exit
  fi

  while IFS= read -r line
  do
    echo "Start processing for target device ID $line"

    # show rosbag info
    rosbag info "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" | tee -a "$LOG"

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
  done < "$DEVICES"

  # backup the ROSBAG file
  cp "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag-$NOW"
fi

# loop for one calibration
echo "start auto calibration...(start = $NOW)" | tee -a "$LOG"
INSTANCE=1
while IFS= read -r line
do
  echo "Start processing for target device ID $line (PARALLEL INSTANCE $INSTANCE)"
  if ! $USE_ROSBAG; then
    echo "Bypass rosbag..."
  fi

  if $USE_ROSBAG; then
    # show rosbag info
    rosbag info "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" | tee -a "$LOG"

    echo "Rosbag topic separating..."
    bash '/home/liu/Desktop/livox-shortcut/ros-rosbag-to-pcd/ros-bag-to-pcd-for-auto-calibration-parallel.sh' -i="/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" -b="${BASE}" -t="$line" -p="$INSTANCE"
    echo "Rosbag topic separating complete"

    # backup the ROSBAG file
    cp "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}.bag-$NOW"

    # rename all files in Base_LiDAR_Frames
    echo "Renaming files..."
    cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration_parallel/$INSTANCE/data/Base_LiDAR_Frames
    i=100000
    for file in $(find * -name '*.pcd' | sort)
    do
      mv $file "$i.pcd"
      i=$((i+1))
    done

    # rename all files in Target-LiDAR-Frames
    cd /home/liu/livox/github-livox-sdk/Livox_automatic_calibration_parallel/$INSTANCE/data/Target-LiDAR-Frames
    i=100000
    for file in $(find * -name '*.pcd' | sort)
    do
      mv $file "$i.pcd"
      i=$((i+1))
    done
    echo "Renaming complete"
  fi

  # real calibration execution
  echo "calibrating for base = ${BASE} target = $line..." | tee -a "$LOG"
  gnome-terminal -x bash -c "bash /home/liu/Desktop/livox-shortcut/auto-calibration/run-parallel.sh -p=$INSTANCE -r="/home/liu/Desktop/out/temp-$INSTANCE.txt"; exec bash && exit"

  INSTANCE=$((INSTANCE+1))
done < "$DEVICES"

NOW=$(date +"%T")
echo "Press Enter if all calibration instance disappeared/completed..."
read key
while [ "$key" != "" ]
do
  read key
done
echo "${GREEN}All calibration complete(finish = $NOW)${NC}" | tee -a "$LOG"

# copy mapping result to Experiment folder
cp "/home/liu/livox/github-livox-sdk/Livox_automatic_calibration/1/data/H-LiDAR-Map-data/H_LiDAR_Map.pcd" "/home/liu/Desktop/Experiment_${DATE}/${EXPERIMENT}-mapping.pcd"

# collecting result
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
fi

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$SECOND_RESULT"
echo "<Livox>" >> "$SECOND_RESULT"
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$THIS_RESULT"
echo "<Livox>" >> "$THIS_RESULT"

INSTANCE=1
while IFS= read -r line
do
  if test -f "$FIRST_RESULT"; then
    python3 '/home/liu/Desktop/livox-shortcut/auto-calibration/calculate-result-parallel.py' $line $FIRST_RESULT $INSTANCE >> "$SECOND_RESULT"
  fi
  python3 '/home/liu/Desktop/livox-shortcut/auto-calibration/generate-result-string-parallel.py' $line $INSTANCE >> "$THIS_RESULT"
  INSTANCE=$((INSTANCE+1))
done < "$DEVICES"

if test -f "$FIRST_RESULT"; then
  echo "</Livox>" >> "$SECOND_RESULT"
fi
echo "</Livox>" >> "$THIS_RESULT"
