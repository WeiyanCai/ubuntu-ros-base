# ubuntu-ros-base

This docker environment is composed of:
* ubuntu 18.04
* tiger vnc server 
* xfce desktop
* ros melodic package
* openssh

It is based on
* osrf/docker_images for [ros_melodic](https://github.com/osrf/docker_images/blob/b075c7dbe56055d862f331f19e1e74ba653e181a/ros/melodic/ubuntu/bionic/ros-core/Dockerfile)
* consol/ubuntu-xfce-vnc for [ubuntu-1604-vnc-desktop](https://hub.docker.com/r/consol/ubuntu-xfce-vnc/)
* JetBrains/clion-remote for [clion-remote](https://github.com/JetBrains/clion-remote)  

and also refers to
* [floodshao/ros-melodic-desktop-vnc](https://hub.docker.com/r/floodshao/ros-melodic-desktop-vnc)

### Build
1. `$ git clone git@github.com:WeiyanCai/ubuntu-ros-base.git`

2. `$ cd ubuntu-ros-base && docker build -t weiyancai/ubuntu-ros-base:latest .`

3. Install the [VNC Viewer](https://www.realvnc.com/en/connect/download/viewer/linux/).

### Run
1. `$ docker run -it -p 5901:5901 -p 6901:6901 -p 127.0.0.1:2222:22 --name ubuntu-ros-base weiyancai/ubuntu-ros-base:latest bash`

2. Open vnc viewer client, type the server address: `localhos:5901`, key in the password: `vncpassword`.

### Work with CLion
1. Clear cached SSH keys `$ ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"`

2. Setup CLion following the steps in [full remote mode](https://www.jetbrains.com/help/clion/remote-projects-support.html?_ga=2.177185446.248654819.1603629508-1928163177.1566133950#CMakeProfile).  
Fill in the SSH credential we set-up in the Dockerfile,  
* `Host`: `localhost` 
* `Port`: `2222`
* `User Name`: `default` 
* `Password`: `password`

