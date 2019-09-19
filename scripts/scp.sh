#!/bin/bash

scp -i ../ssh/id_rsa * centos@$1:

echo "ssh -i ../ssh/id_rsa centos@$1"
