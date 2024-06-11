# YADEinD
[![Docker Image CI](https://github.com/jscblack/YADED/actions/workflows/docker-image.yml/badge.svg)](https://github.com/jscblack/YADED/actions/workflows/docker-image.yml)

Yet Another Development Environment in Docker

## Example
Recommended Font:**MesloLGS NF**
![image](https://github.com/jscblack/YADED/assets/33062157/7dac7590-1582-42d5-a845-ddd5a6c5e02e)

## Feature
* Based on Ubuntu 22.04
* Out-of-the-box Zsh with pre-configured Power10k theme
* Pre-installed useful Zsh plugins (autosuggestions, completions, syntax-highlighting)
* Redirecting rm to ensure file safety
* Pre-installed common development toolkits, providing consistent and portable development environment, alleviating the hassle of environment conflicts between different projects

## Usage
1. Start the container. Modify the name and port as you want

   ``docker run -d --name <container_name> -p <public_port>:22 -v $(pwd)/<workspace_dir>:/root/workspace registry.cn-hangzhou.aliyuncs.com/jscblack/yaded:latest``

2. Once the container started, it will generate a random 8 digit password and set it to root. The initial password should be logged in the docker log, you can check it

    ``docker logs <container_name> | grep password``

3. Connect the dev container from remote SSH, such as visual studio code. Once logged in, change the password immediately

    ``echo "root:<your_password>" | chpasswd``

4. Enjoy
