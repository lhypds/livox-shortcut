# Params 1. input rosbag file path 2. base topic 3. targe topic
# Example: bash '/home/liu/livox/livox-shortcut/ros-rosbag-to-pcd/ros-bag-to-pcd-for-auto-calibration.sh' -i="/home/liu/Desktop/Experiment_20210721/test1.bag" -b="3JEDJ6400100591" -t="3JEDHC900100491"
for i in "$@"
do
case $i in
    -b=*|--base=*)
    BASE="${i#*=}"
    ;;
    -t=*|--target=*)
    TARGET="${i#*=}"
    ;;
    -i=*|--rosbag=*)
    ROSBAG="${i#*=}"
    ;;
esac
done

# Create a roscore process
tmux new-session -d -s "roscore" -n "ROSCORE"
sleep 1
tmux send-key -t "roscore" 'roscore' Enter
echo Rosbag = ${ROSBAG}
echo Base Device = ${BASE}
echo Target Device = ${TARGET}
sleep 2

# Cleanup
rm /home/liu/livox/Livox_automatic_calibration/data/Base_LiDAR_Frames/*.pcd
rm /home/liu/livox/Livox_automatic_calibration/data/Target-LiDAR-Frames/*.pcd
rm /home/liu/livox/out/*

# Convert file
rosbag filter ${ROSBAG} '/home/liu/livox/out/topic_base.bag' "topic == '/livox/lidar_${BASE}'"
rosbag filter ${ROSBAG} '/home/liu/livox/out/topic_target.bag' "topic == '/livox/lidar_${TARGET}'"
rosrun pcl_ros bag_to_pcd /home/liu/livox/out/topic_base.bag /livox/lidar_${BASE} /home/liu/livox/Livox_automatic_calibration/data/Base_LiDAR_Frames
rosrun pcl_ros bag_to_pcd /home/liu/livox/out/topic_target.bag /livox/lidar_${TARGET} /home/liu/livox/Livox_automatic_calibration/data/Target-LiDAR-Frames
tmux kill-server

