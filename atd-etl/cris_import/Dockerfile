FROM ubuntu:22.04

# Set the timezone
RUN ln -snf /usr/share/zoneinfo/America/Chicago /etc/localtime && echo America/Chicago > /etc/timezone
RUN apt-get update && apt-get install -y tzdata

RUN apt-get -y upgrade
RUN apt-get install -y aptitude magic-wormhole vim black python3-pip

# install zip archive tool & pgloader for CRIS export use
RUN apt-get install -y p7zip-full pgloader

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# bastion host support for local dev
RUN apt-get install -y openssh-server
# sshd needs this folder for connection tracking
RUN mkdir /run/sshd
# generate a keypair for ssh
RUN ssh-keygen -t ed25519 -C "airflow@airflow" -f /root/.ssh/id_ed25519 -q -N ""
# allow ssh to localhost
RUN cat /root/.ssh/id_ed25519.pub > /root/.ssh/authorized_keys
# disable the "are you sure you want to connect" prompt
RUN printf "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

COPY ./ssh_keys/id_rsa /root/.ssh/id_rsa
COPY ./ssh_keys/id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa.pub

COPY entrypoint.sh /entrypoint.sh

WORKDIR /app
CMD ["/entrypoint.sh"]
