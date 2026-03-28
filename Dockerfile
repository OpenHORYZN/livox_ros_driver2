# Dockerfile for Livox ROS2 Driver (Humble)
FROM ros:humble-ros-base

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libapr1-dev \
    libpcl-dev \
    ros-humble-pcl-conversions \
    ros-humble-pcl-ros \
    ros-$ROS_DISTRO-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/*

# Build and install Livox-SDK2
RUN git clone https://github.com/Livox-SDK/Livox-SDK2.git /tmp/Livox-SDK2 && \
    cd /tmp/Livox-SDK2 && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    rm -rf /tmp/Livox-SDK2

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Create ROS2 workspace and copy source
RUN mkdir -p /ros2_ws/src
COPY . /ros2_ws/src/livox_ros_driver2/

# Build the driver
WORKDIR /ros2_ws/src/livox_ros_driver2
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && ./build.sh humble"

# Setup environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /ros2_ws/install/setup.bash" >> ~/.bashrc

WORKDIR /ros2_ws

CMD ["/bin/bash"]
