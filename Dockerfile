FROM alpine:latest

# Install Postfix, OpenDKIM, and their dependencies, and Dovecot for SASL
RUN apk add --no-cache postfix opendkim opendkim-utils dovecot curl rspamd

# Configure Postfix for send-only, integrate with RSPAMD, enable SASL, and enable STARTTLS
RUN postconf -e 'inet_interfaces = all' && \
    postconf -e 'mydestination = localhost.localdomain, localhost' && \
    postconf -e 'smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination' && \
    postconf -e 'mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128' && \
    postconf -e 'milter_protocol = 6' && \
    postconf -e 'milter_default_action = accept' && \
    postconf -e 'smtpd_milters = inet:localhost:11332' && \
    postconf -e 'non_smtpd_milters = inet:localhost:11332' && \
    postconf -e 'smtpd_sasl_auth_enable = yes' && \
    postconf -e 'smtpd_sasl_type = dovecot' && \
    postconf -e 'smtpd_sasl_path = private/auth' && \
    postconf -e 'smtpd_sasl_security_options = noanonymous' && \
    postconf -e 'broken_sasl_auth_clients = yes' && \
    postconf -e 'smtpd_recipient_restrictions = permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination' && \
    postconf -e 'smtp_tls_security_level = may' && \
    postconf -e 'smtp_tls_loglevel = 1'

# Configure RSPAMD
COPY etc/rspamd /etc/rspamd
RUN chown -R rspamd:rspamd /etc/rspamd && \
    chmod -R 644 /etc/rspamd

# Configure Dovecot
COPY etc/dovecot.conf /etc/dovecot/dovecot.conf
RUN chown root:root /etc/dovecot/dovecot.conf && \
    chmod 644 /etc/dovecot/dovecot.conf

# Create a startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'rspamd -u rspamd -g rspamd &' >> /start.sh && \
    echo 'dovecot' >> /start.sh && \
    echo 'postconf -e "myhostname = $MAIL_HOST"' >> /start.sh && \
    echo 'postconf -e "myorigin = $DOMAIN"' >> /start.sh && \
    echo 'postconf -e "masquerade_domains = $DOMAIN"' >> /start.sh && \
    echo 'postconf -e "inet_interfaces = all"' >> /start.sh && \
    echo 'if [ "$ENABLE_SMTPD_TLS" = "true" ]; then' >> /start.sh && \
    echo '    postconf -e "smtpd_tls_security_level = may"' >> /start.sh && \
    echo '    postconf -e "smtpd_tls_auth_only = no"' >> /start.sh && \
    echo '    postconf -e "smtpd_tls_loglevel = 1"' >> /start.sh && \
    echo 'else' >> /start.sh && \
    echo '    postconf -e "smtpd_tls_security_level = none"' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'postfix start-fg' >> /start.sh && \
    chmod +x /start.sh

# Create health check script
# RUN echo '#!/bin/sh' > /healthcheck.sh && \
#     echo 'if ! pgrep postfix > /dev/null; then exit 1; fi' >> /healthcheck.sh && \
#     echo 'if ! pgrep rspamd > /dev/null; then exit 1; fi' >> /healthcheck.sh && \
#     echo 'if ! pgrep dovecot > /dev/null; then exit 1; fi' >> /healthcheck.sh && \
#     echo 'if ! curl -s --max-time 5 telnet://localhost:25 > /dev/null; then exit 1; fi' >> /healthcheck.sh && \
#     echo 'exit 0' >> /healthcheck.sh && \
#     chmod +x /healthcheck.sh

# Expose the SMTP port
EXPOSE 25

# Set the startup command
CMD ["/start.sh"]

# Add health check
#HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD ["/healthcheck.sh"]
