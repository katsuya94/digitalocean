#!/usr/bin/env bash
set -e

ansible-playbook -i hosts.rb user.yml \
  --user $1\
  --private-key $4\
  --ask-become-pass\
  --extra-vars "user=$2 pub_key_path=$3"
