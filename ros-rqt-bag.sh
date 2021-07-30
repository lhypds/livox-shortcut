tmux new-session -d -s "roscore" roscore
sleep 2
rqt_bag /home/liu/Desktop/out/topic_target.bag
tmux kill-session
