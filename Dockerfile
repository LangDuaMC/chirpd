FROM alpine:latest

# Install Postfix, OpenDKIM, and their dependencies
RUN apk add --no-cache postfix opendkim opendkim-utils

# Configure Postfix for send-only and integrate with OpenDKIM
RUN postconf -e 'inet_interfaces = loopback-only' && \
    postconf -e 'mydestination = localhost.localdomain, localhost' && \
    postconf -e 'smtpd_relay_restrictions = permit_mynetworks, reject_unauth_destination' && \
    postconf -e 'mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128' && \
    postconf -e 'milter_protocol = 2' && \
    postconf -e 'milter_default_action = accept' && \
    postconf -e 'smtpd_milters = inet:localhost:8891' && \
    postconf -e 'non_smtpd_milters = inet:localhost:8891'

# Configure OpenDKIM
RUN mkdir -p /etc/opendkim/keys && \
    chown -R opendkim:opendkim /etc/opendkim && \
    echo "SOCKET=\"inet:8891@localhost\"" >> /etc/opendkim/opendkim.conf && \
    echo "PIDFILE=/var/run/opendkim/opendkim.pid" >> /etc/opendkim/opendkim.conf && \
    echo "MODE=sv" >> /etc/opendkim/opendkim.conf && \
    echo "CANONICALIZATION=relaxed/simple" >> /etc/opendkim/opendkim.conf && \
    echo "SUBDOMAINS=yes" >> /etc/opendkim/opendkim.conf

# Create a startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'mkdir -p /var/run/opendkim' >> /start.sh && \
    echo 'chown opendkim:opendkim /var/run/opendkim' >> /start.sh && \
    echo 'opendkim' >> /start.sh && \
    echo 'postfix start-fg' >> /start.sh && \
    chmod +x /start.sh

# Expose the SMTP port
EXPOSE 25

# Set the startup command
CMD ["/start.sh"]
