FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow
RUN apt-get update && apt-get install -y openssh-server python3-pip inetutils-ping net-tools curl
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "root:root" | chpasswd

EXPOSE 5000 3306

ENTRYPOINT service ssh start && tail -f /dev/null