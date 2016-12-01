#!/bin/bash
eval `ssh-agent -s`
pass=''

expect << EOF
  spawn ssh-add $1
  expect "Enter passphrase"
  send "$pass\r"
  expect eof
EOF