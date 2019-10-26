#!/bin/bash -e

# https://moomindani.wordpress.com/2014/09/17/linux-command-ip-address/
hostname -I | cut -f1 -d' '
