rm /home/liu/livox/out/*
cd /home/liu/livox/out
tmux new-session -d -s "roscore" roscore
sleep 2
rosbag record -a
tmux kill-session
