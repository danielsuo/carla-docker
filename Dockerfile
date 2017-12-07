FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

ARG OAUTH_TOKEN

RUN apt-get update

# Install build tools and dependencies
RUN apt-get install -y \
      build-essential \
      clang-3.9 \
      git \
      cmake \
      ninja-build \
      python3-pip \
      python3-requests \
      python-dev \
      tzdata \
      sed \
      curl \
      wget \
      unzip \
      autoconf \
      libtool

# Install UE4 dependencies
RUN apt-get install -y \
      bison \
      flex \
      freeglut3 \
      freeglut3-dev \
      xserver-xorg \
      xserver-xorg-core \
      libgl1-mesa-glx \
      libgl1-mesa-dri \
      libz-dev \
      libglew-dev \
      libqt4-dev \
      dos2unix \
      xdg-user-dirs \
      mono-xbuild \
      mono-dmcs \
      mono-devel \
      libmono-system-data-datasetextensions4.0-cil \
      libmono-windowsbase4.0-cil \
      libmono-system-web-extensions4.0-cil \
      libmono-system-management4.0-cil \
      libmono-system-xml-linq4.0-cil \
      libmono-system-io-compression4.0-cil \
      libmono-system-io-compression-filesystem4.0-cil \
      libmono-microsoft-build-tasks-v4.0-4.0-cil \
      libmono-system-runtime4.0-cil \
      mono-reference-assemblies-4.0 \
      libfreetype6-dev \
      libgtk-3-dev \
      clang-3.8

# Install Python dependencies
RUN pip3 install -U \
      pip \
      protobuf \
      numpy \
      Pillow \
      pygame

# Update clang
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-3.9/bin/clang++ 100
RUN update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-3.9/bin/clang 100

# Create working directory
RUN useradd -m carla
USER carla
ENV HOME /home/carla
WORKDIR $HOME

# Install UnrealEngine
# NOTE: requires signing up at https://unrealengine.com to access repository
RUN git clone https://$OAUTH_TOKEN@github.com/EpicGames/UnrealEngine -b release $HOME/deps/UnrealEngine
WORKDIR $HOME/deps/UnrealEngine
RUN ./Setup.sh -exclude=Win32 -exclude=Win64 -exclude=Mac -exclude=Android -exclude=IOS -exclude=HTML5 && \
      ./GenerateProjectFiles.sh && \
      make
ENV UE4_ROOT $HOME/deps/UnrealEngine
WORKDIR $HOME

# Install Carla
RUN git clone https://github.com/carla-simulator/carla
WORKDIR $HOME/carla
RUN ./Setup.sh

# TODO: ./Rebuild.sh tries to launch the UE4Editor at the end, which will fail
RUN ./Rebuild.sh; exit 0
RUN make check
WORKDIR $HOME
