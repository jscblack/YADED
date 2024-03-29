FROM ubuntu:22.04
# modify as you want
ENV TZ=Asia/Shanghai 
ENV LANG=en_US.UTF-8

MAINTAINER jscblack@china

#==================Base Environment Begin==================#
RUN apt update \
	&& apt install -y apt-transport-https ca-certificates \
	&& sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list \
    	&& sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

RUN apt update && apt install -y locales \
        && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
	&& apt install -y apt-utils openssh-client openssh-server

RUN apt install -y tzdata \
        && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir /var/run/sshd \
        && mkdir /root/.ssh

RUN echo "root:123456" | chpasswd \
        && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
#==================Base Environment End==================#



#==================Dev Environment Begin==================#
RUN apt install -y iputils-ping net-tools iproute2 traceroute # network

RUN apt install -y build-essential cmake # basic compiler

RUN apt install -y git vim nano # misc

RUN apt install -y lsb-release wget software-properties-common gnupg # llvm dependency

RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" # llvm toolchain
#==================Dev Environment End==================#



#==================ZSH Environment Begin==================#
RUN apt install -y zsh

RUN sh -c "$(wget -O- https://gist.githubusercontent.com/jscblack/5c7b4b4f4c18ed2af7ac48ea12030a54/raw/d0866278a6dbb4d4f5d59d138dc1cc5f465ed157/chiang-zsh-in-docker.sh)" -- \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting
RUN chsh -s /bin/zsh
#==================ZSH Environment End==================#

#==================Post Process==================#
RUN rm -rf /var/lib/apt/lists/*
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
