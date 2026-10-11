#!/bin/sh
# MFA 初期化後に MFA 必須の sshd_config を適用する (sudo 経由で login.user が実行可能な唯一の特権コマンド)
set -eu
mv /root/sshd_config /etc/ssh/sshd_config
kill -HUP "$(cat /run/sshd.pid)"
