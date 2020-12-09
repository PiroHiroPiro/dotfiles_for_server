#!/bin/bash -e

# https://qiita.com/ksugawara61/items/887ddd1792d7d5dabb25
publicip=$(curl inet-ip.info)
# https://moomindani.wordpress.com/2014/09/17/linux-command-ip-address/
privateip=$(hostname -I | cut -f1 -d' ')

echo "${publicip}(${privateip})"
