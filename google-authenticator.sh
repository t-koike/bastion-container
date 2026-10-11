if [ "$USER" != "root" -a "$USER" != "ec2-user" ]; then
  if [ ! -f "$HOME/.google_authenticator" ]; then
    trap 'exit' SIGINT
    echo "Initialize google-authenticator"
    /usr/bin/google-authenticator -t -d -W -u -f
    sudo /usr/local/sbin/enable-mfa
    trap -- SIGINT
  fi
fi
