rm /home/liu/Desktop/out/*
cd /home/liu/Desktop/out
tmux new-session -d -s "roscore" roscore
sleep 2
rosbag record -a
tmux kill-session
