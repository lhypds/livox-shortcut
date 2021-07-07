tmux new-session -d -s "roscore" roscore
sleep 2
rqt_bag /home/liu/Desktop/Experiment_20210707/test9.bag
tmux kill-session
