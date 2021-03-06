# This Dockerfile is used to build a vnc image based on Ubuntu 18.04

FROM ubuntu:18.04

LABEL io.k8s.description="A base container with vnc, xfce window manager, chromium, ros and ssh daemon" \
      io.k8s.display-name="A base Container based on Ubuntu 18.04" \
      io.openshift.expose-services="6901:http,5901:xvnc" \
      io.openshift.tags="vnc, ubuntu, xfce, ros" \
      io.openshift.non-scalable=true

### Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport: 6901, connect via http://IP:6901/?password=vncpassword
# ssh port: 22
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    SSH_PORT=22
EXPOSE $VNC_PORT $NO_VNC_PORT $SSH_PORT

### Environment config
ARG USER_NAME=default
ENV HOME=/home/$USER_NAME

### Add user and password
RUN useradd -m $USER_NAME \
    && yes password | passwd $USER_NAME

WORKDIR $HOME

ENV TERM=xterm \
    STARTUPDIR=$HOME/startup \
    INST_SCRIPTS=$HOME/install \
    NO_VNC_HOME=$HOME/no_vnc \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false

### Add all install scripts for further steps
ARG SH_DIR=./xfce_exec
ADD $SH_DIR/common/install/ $INST_SCRIPTS/
ADD $SH_DIR/ubuntu/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Setup timezone
ENV TZ 'Asia/Shanghai'
RUN echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -q -y tzdata \
    && rm /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

### Use tsinghua mirror in sources list
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install custom fonts
RUN $INST_SCRIPTS/install_custom_fonts.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install firefox and chrome browser
#RUN $INST_SCRIPTS/firefox.sh
RUN $INST_SCRIPTS/chrome.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD $SH_DIR/common/xfce/ $HOME/

### Configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD $SH_DIR/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

RUN apt-get update && apt-get install -q -y \
    bash-completion \
    build-essential \
    cmake \
    dirmngr \
    gnupg2 \
    lsb-release \
    libgtest-dev \
    openssh-client \
    pkg-config \
    sudo \
    ssh \
    vim \
    && rm -rf /var/lib/apt/lists/*

### Install ros (refer to https://github.com/osrf/docker_images/blob/b075c7dbe56055d862f331f19e1e74ba653e181a/ros/melodic/ubuntu/bionic/ros-core/Dockerfile)
ENV ROS_DISTRO melodic

### Add sources list and app key
RUN sh -c '. /etc/lsb-release && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list' \
    && apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

### Install bootstrap tools
RUN apt-get update && apt-get install -q -y \
    python-catkin-tools \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

### Install ros
RUN apt-get update && apt-get install -q -y \
    ros-melodic-desktop-full \
    && rm -rf /var/lib/apt/lists/*

### Bootstrap rosdep
RUN echo "151.101.84.133  raw.githubusercontent.com" >> /etc/hosts \
    && rosdep init && rosdep update --rosdistro $ROS_DISTRO

### Configure sshd and ros environment
RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
    ) > /etc/ssh/sshd_config_clion_remote \
    && mkdir /run/sshd \
    && echo "/usr/sbin/sshd -f /etc/ssh/sshd_config_clion_remote" >> $HOME/.bashrc \
    && echo "source /opt/ros/melodic/setup.bash" >> $HOME/.bashrc

### Change USER to 0 to get the root
RUN adduser $USER_NAME sudo
USER $USER_NAME

ENTRYPOINT ["/home/default/startup/vnc_startup.sh"]
CMD ["--wait"]
