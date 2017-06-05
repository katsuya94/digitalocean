FROM debian:jessie
RUN apt-get update
RUN apt-get install -y openssh-server
RUN apt-get install -y python
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
COPY root_id_rsa.pub /root/.ssh/authorized_keys
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
