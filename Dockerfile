FROM alpine:latest

#Both these ports are only exposed on the internal docker network

# This is the port we're going to reverse tunnel
EXPOSE 8080

# This is the normal SSHd port (this gets mapped to 
#  external port 2222 in the docker-compose.yml file)
EXPOSE 22

RUN apk --update add openssh \
    && sed -i 's/#GatewayPorts no.*/GatewayPorts\ yes/' /etc/ssh/sshd_config \
    && rm -rf /var/cache/apk/*

RUN \
    passwd -d root && \
    adduser -D -s /bin/ash tunnelingus && \
    passwd -u tunnelingus && \
    chown -R tunnelingus:tunnelingus /home/tunnelingus && \
    ssh-keygen -A

COPY authorized_keys /home/tunnelingus/.ssh/authorized_keys

CMD /usr/sbin/sshd -D
