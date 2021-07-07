tmux new-session -d -s "roscore" roscore
sleep 2
rosbag play ~/Desktop/Experiment_20210707/test9.bag /livox/lidar_3JEDHB300100891:=/topic1
tmux kill-session
