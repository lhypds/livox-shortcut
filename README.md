
Livox Shortcut
==============


File Tree
---------

```
~/code                          All code backups  
~/livox  
    /Livox\ Viewer              Livox Viewer  
    /livox-shortcut
    /Livox-SDK
    /[Other Github SDK Repos]  
    /out                        Output files
~/Desktop  
    /Experiment_xxx  
~/catkin_ws                     Livox Mapping
~/ws_livox                      Livox ROS Driver
```

* File Move  
```
~\livox\github-livox-sdk\* -> livox\*
~\Desktop\out -> ~\livox\out
```


LiDAR Device List
-----------------

3JEDHC900100491  Base     Center  
3JEDJ5Q00100431  Target1  Back  
3JEDJ6400100191  Target2  Right  
3JEDJ6400100241  Target3  Back Right  
3JEDJ6400100291  Target4  Back Left  
3JEDJ6400100591  Target5  Left  


Record ROS Bag
--------------

* Method 1

1. Record lvx file
2. ros-driver-lvx-to-rosbag

* Method 2

1. ros-drive-recieve-data
2. Use ros-rqt.sh to record


Auto Calibration
----------------

1. Record ros bag (refer "Record ROS Bag")
3. ros-rosbag-to-pcd (use auto calibraton)
4. auto-calibration.sh
