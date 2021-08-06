tmux new-session -d -s "roscore" roscore
sleep 2
rqt_bag
sleep 20
tmux kill-session
