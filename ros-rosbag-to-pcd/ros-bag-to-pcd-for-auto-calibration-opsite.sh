rm /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Base_LiDAR_Frames/*.pcd
rm /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Target-LiDAR-Frames/*.pcd
tmux new-session -d -s "roscore" roscore
sleep 2
rm /home/liu/Desktop/out/*
rosbag filter '/home/liu/Desktop/Experiment_20210721/test1.bag' '/home/liu/Desktop/out/topic_base.bag' "topic == '/livox/lidar_3JEDHC900100491'"
rosbag filter '/home/liu/Desktop/Experiment_20210721/test1.bag' '/home/liu/Desktop/out/topic_target.bag' "topic == '/livox/lidar_3JEDJ6400100591'"
rosrun pcl_ros bag_to_pcd /home/liu/Desktop/out/topic_base.bag /livox/lidar_3JEDHC900100491 /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Base_LiDAR_Frames
rosrun pcl_ros bag_to_pcd /home/liu/Desktop/out/topic_target.bag /livox/lidar_3JEDJ6400100591 /home/liu/livox/github-livox-sdk/Livox_automatic_calibration/data/Target-LiDAR-Frames
tmux kill-server
