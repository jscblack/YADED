# YADEinD
[![Docker Image CI](https://github.com/jscblack/YADED/actions/workflows/docker-image.yml/badge.svg)](https://github.com/jscblack/YADED/actions/workflows/docker-image.yml)

Yet Another Development Environment in Docker

Required Font:**MesloLGS NF**

Example:
![image](https://user-images.githubusercontent.com/33062157/196014804-635d846d-9647-4a02-8f92-cb3f73b606aa.png)


Usage:``docker run -d --name <container_name> -p <public_port>:22 -v $(pwd)/<workspace_dir>:/root/workspace registry.cn-hangzhou.aliyuncs.com/jscblack/yaded:latest``

Once the container started, it will generate a random 8 digit password and set it to root. The initial password should be logged in the docker log, you can check it ``docker log <container_name> | grep password``
