# ubuntu-ros-base

This docker environment is based on:
* osrf/docker_images for [ros_melodic](https://github.com/osrf/docker_images/blob/b075c7dbe56055d862f331f19e1e74ba653e181a/ros/melodic/ubuntu/bionic/ros-core/Dockerfile)
* consol/ubuntu-xfce-vnc for [ubuntu-1604-vnc-desktop](https://hub.docker.com/r/consol/ubuntu-xfce-vnc/)
and also refers to:
* [floodshao/ros-melodic-desktop-vnc](https://hub.docker.com/r/floodshao/ros-melodic-desktop-vnc)

# Build
```
$ docker build -it weiyancai/ubuntu-ros-base:latest .
```

# Run
1. `$ docker run -it -p 5901:5901 -p 6901:6901 -p 127.0.0.1:2222:22 --name ubuntu-ros-base weiyancai/ubuntu-ros-base:latest /bin/bash`
2. open vnc viewer client, type the server address: `localhos:5901`, key in the password: `vncpassword`

# Work with CLion
1. Clear cached SSH keys:
```
$ ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"
```

2. Setup CLion following the steps in [Full remote mode](https://www.jetbrains.com/help/clion/remote-projects-support.html?_ga=2.177185446.248654819.1603629508-1928163177.1566133950#CMakeProfile)
Fill in the SSH credential we set-up in the Dockerfile,
* `Host`: `localhost` 
* `Port`: `2222`
* `User Name`: `default` 
* `Password`: `password`

