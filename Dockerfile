FROM ubuntu:22.04

# Metadata
LABEL maintainer="jscblack@china"

# Set environment variables
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8

# Define the package lists for easy maintenance
# Base packages
ARG BASE_PACKAGES="\
    apt-transport-https \
    ca-certificates \
    locales \
    apt-utils \
    openssh-client \
    openssh-server \
    tzdata"

# Network tools
ARG NETWORK_PACKAGES="\
    iputils-ping \
    net-tools \
    iproute2 \
    traceroute"

# Compiler tools
ARG COMPILER_PACKAGES="\
    build-essential \
    gdb \
    cmake"

# Miscellaneous tools
ARG MISC_PACKAGES="\
    git \
    zip \
    unzip \
    vim \
    nano"

# LLVM dependencies
ARG LLVM_DEPENDENCIES="\
    lsb-release \
    wget \
    software-properties-common \
    gnupg"

# ZSH shell
ARG ZSH_PACKAGES="\
    zsh"

# Base Environment Setup
RUN apt-get update \
    && apt-get install -y --no-install-recommends $BASE_PACKAGES $NETWORK_PACKAGES $COMPILER_PACKAGES $MISC_PACKAGES $LLVM_DEPENDENCIES $ZSH_PACKAGES \
    # Configure locales
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    # Configure timezone
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    # SSH setup
    && mkdir /var/run/sshd \
    && mkdir /root/.ssh \
    && echo "root:123456" | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# Install LLVM toolchain
RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" \
    && current_llvm_stable=$(wget -qO- https://apt.llvm.org/llvm.sh | grep -oP 'CURRENT_LLVM_STABLE=\K\d+') \
    && ln -sf "/usr/bin/clang-$current_llvm_stable" /usr/local/bin/clang \
    && ln -sf "/usr/bin/clang++-$current_llvm_stable" /usr/local/bin/clang++ \
    && ln -sf "/usr/bin/clangd-$current_llvm_stable" /usr/local/bin/clangd

# Install and configure ZSH with plugins
RUN sh -c "$(wget -O- https://gist.githubusercontent.com/jscblack/5c7b4b4f4c18ed2af7ac48ea12030a54/raw/d595af7c10b731d66e1e6866034130db03858af1/chiang-zsh-in-docker.sh)" -- \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p https://github.com/mattmc3/zsh-safe-rm \
    && chsh -s /bin/zsh

# Install NVM, Node.js and npm
ENV NVM_DIR=/root/.nvm
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install --lts \
    && nvm use --lts \
    && nvm alias default "lts/*"

# Make node/npm available system-wide via symlinks
RUN . "$NVM_DIR/nvm.sh" \
    && ln -sf "$(which node)" /usr/local/bin/node \
    && ln -sf "$(which npm)" /usr/local/bin/npm \
    && ln -sf "$(which npx)" /usr/local/bin/npx \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.zshrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.zshrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.zshrc \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.bashrc

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port and set default command
EXPOSE 22

# Copy entrypoint
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Specify the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
