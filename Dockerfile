FROM nvidia/cuda:10.0-cudnn7-devel
LABEL maintainer="Emma Svensson"
ENV DEBIAN_FRONTEND=noninteractive

###################################################

WORKDIR /
# Installing python2 and python3
RUN apt-get update && \
	apt install -y --no-install-recommends \
		python3-pip \
		python-pip \
		python3 \
		python
# Uppgrade pip and pip3
RUN pip3 install --upgrade pip setuptools && \
	pip install --upgrade pip

# Install git, p7zip (to extract 7z zip files),
# X and xvfb so we can SEE the action using a remote desktop access (VNC)
# and more.
RUN apt-get update && apt-get install -y \
	git \
	p7zip-full \
	x11vnc \
	xvfb \
	fluxbox \
	wmctrl \
	wget \
	vim 

# Installing a bunch of Python Packages
RUN pip3 install \
	pandas \
	scikit-learn \
	joblib==0.11 \
	wget \
	open3d \
	open3d-python \
	dask

# Needed for converting large semantic3d txt files to pcd format
RUN pip3 install dask[dataframe] --upgrade
	
# For visualizations with tangent convolution: numpy == 1.16.1 is needed 
# but so far visualizations doens't work inside this docker bacouse of a problem with OpenGL 
	
# Installing Tensorflow (GPU)
RUN pip3 install tensorflow-gpu

# Build Open3d from source, needed for the tangent convolutional network
WORKDIR /home/student/
RUN git clone https://github.com/tatarchm/Open3D.git
RUN set -ev && apt-get install -y \
	xorg-dev \
	libglu1-mesa-dev \
	libgl1-mesa-glx \
	libglew-dev \
	libglfw3-dev \
	libjsoncpp-dev \
	libeigen3-dev \
	libpng-dev \
	libjpeg-dev \
	python-dev \
	python3-dev \
	python-tk \
	python3-tk 

WORKDIR /home/student/Open3D/build
RUN apt-get update && \
	apt-get -y install cmake protobuf-compiler && \
	cmake ../src && \
	make

# Clean up
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /cudnn-8.0-linux-x64-v7.tgz && \
	rm -rf /cuda/

# Clone original repository for the tangent convolutional network 
WORKDIR /home/student/#RUN git clone https://github.com/tatarchm/tangent_conv.git
#WORKDIR /home/student/tangent_conv

# Copy files for the tangent convolutional network (Semantic3D)
# data/raw/semantic3d is needed to run tc.py --precompute
#COPY data /home/student/tangent_conv/data
# data/param/semantic3d/0p1/ contains the files generated by tc.py --precompute (dhnrgb) 
# and is needed for tc.py --train
#COPY data /home/student/tangent_conv/data

# Clone CoRob for clustering
WORKDIR /home/student/
RUN git clone https://github.com/emmas96/CoRob.git
WORKDIR /home/student/CoRob

# Copy files for CoRob
COPY RawData /home/student/CoRob/Clustering/RawData
