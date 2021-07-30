# Params 1. input lvx file path
# Example: bash '/home/liu/Desktop/livox-shortcut/ros-driver-lvx-to-rosbag/livox-ros-driver-launch-lvx-to-rosbag-multi-topic.sh' -i="/home/liu/Desktop/Experiment_20210721/test1.lvx"
for i in "$@"
do
case $i in
    -i=*|--rosbag=*)
    LVX="${i#*=}"
    ;;
esac
done

source ~/ws_livox/devel/setup.sh
cd ~/ws_livox/src/livox_ros_driver/launch
roslaunch livox_ros_driver lvx_to_rosbag_multi_topic.launch lvx_file_path:="${LVX}"

