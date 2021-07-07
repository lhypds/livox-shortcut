rm /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Base_LiDAR_Frames/*.pcd
rm /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Target-LiDAR-Frames/*.pcd
tmux new-session -d -s "roscore" roscore
sleep 2
rm /home/liu/Desktop/out/*
rosbag filter '/home/liu/Desktop/Experiment_20210707/test11.bag' '/home/liu/Desktop/out/topic891.bag' "topic == '/livox/lidar_3JEDHB300100891'"
rosbag filter '/home/liu/Desktop/Experiment_20210707/test11.bag' '/home/liu/Desktop/out/topic641.bag' "topic == '/livox/lidar_3JEDHB300100641'"
rosrun pcl_ros bag_to_pcd /home/liu/Desktop/out/topic891.bag /livox/lidar_3JEDHB300100891 /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Base_LiDAR_Frames
rosrun pcl_ros bag_to_pcd /home/liu/Desktop/out/topic641.bag /livox/lidar_3JEDHB300100641 /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Target-LiDAR-Frames
tmux kill-server
