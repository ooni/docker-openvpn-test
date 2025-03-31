# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM alpine:edge

LABEL maintainer="Tomas Nevar <tomas@lisenet.com>"

# Testing: pamtester
RUN apk add --update openvpn iptables iptables-legacy bash easy-rsa openvpn-auth-pam google-authenticator libqrencode && \
    apk update && apk upgrade && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* && \
    rm -f /sbin/iptables && \
    ln -s /sbin/iptables-legacy /sbin/iptables

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
