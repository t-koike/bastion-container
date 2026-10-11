FROM ubuntu:26.04
LABEL maintainer="t-koike"

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-server sudo libpam-google-authenticator \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/run/sshd

# sshd: 初期状態はパスワード認証を無効化
RUN sed -i \
      -e 's/^#\?PermitRootLogin .*/PermitRootLogin no/' \
      -e 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' \
      /etc/ssh/sshd_config \
 && echo "export VISIBLE=now" >> /etc/profile

# PAM: common-auth を Google Authenticator に置き換え
RUN sed -i \
      -e '/^@include common-auth$/a auth    required    pam_google_authenticator.so' \
      -e 's/^@include common-auth$/#@include common-auth/' \
      /etc/pam.d/sshd

COPY sshd_config /root/sshd_config
COPY google-authenticator.sh /etc/profile.d/google-authenticator.sh
COPY enable-mfa.sh /usr/local/sbin/enable-mfa
COPY id_rsa.pub /tmp/authorized_keys

RUN useradd -m -d /home/login.user -s /bin/bash login.user \
 && install -d -m 700 -o login.user -g login.user /home/login.user/.ssh \
 && install -m 600 -o login.user -g login.user /tmp/authorized_keys /home/login.user/.ssh/authorized_keys \
 && rm /tmp/authorized_keys \
 && chmod 755 /usr/local/sbin/enable-mfa \
 && echo "login.user ALL=(root) NOPASSWD: /usr/local/sbin/enable-mfa" > /etc/sudoers.d/login.user \
 && chmod 440 /etc/sudoers.d/login.user

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
