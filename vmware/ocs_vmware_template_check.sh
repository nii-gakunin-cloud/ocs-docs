#!/bin/bash

grep -q '^ID=ubuntu' /etc/os-release \
  || echo "OS is not Ubuntu" >&2

getent passwd | grep -q '^ubuntu:' \
  || echo "The 'ubuntu' user does not exist." >&2

sshd -Tf /etc/ssh/sshd_config | grep -q '^port 22' \
  || echo "SSH server is not running on port 22." >&2

sshd -Tf /etc/ssh/sshd_config | grep -q '^passwordauthentication yes' \
  || echo "Password authentication for SSH is disabled." >&2

grep '^ubuntu' /etc/sudoers | grep -q NOPASSWD \
  || grep '^ubuntu' /etc/sudoers.d/* | grep -q NOPASSWD \
  || echo "'ubuntu' user cannot use sudo to gain root privileges without a password." >&2

systemctl is-enabled docker >/dev/null \
  || echo "docker does not install or start automatically on VM boot." >&2

systemctl is-enabled open-vm-tools >/dev/null \
  || echo "open-vm-tools does not install or start automatically on VM boot." >&2
