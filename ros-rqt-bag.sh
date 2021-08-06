tmux new-session -d -s "roscore" roscore
sleep 2
rqt_bag
tmux kill-session
