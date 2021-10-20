tmux new-session -d -s "roscore" roscore
sleep 2
tmux new-session -d -s "recieve"
gnome-terminal -x bash -c "tmux attach -t "recieve"; exec bash && exit"
tmux send-key -t "recieve" 'bash '/home/liu/livox/livox-shortcut/ros-driver-recieve-data/livox-ros-driver-launch-livox-hub-multi-topic.sh'' Enter
rqt_bag
tmux kill-session
