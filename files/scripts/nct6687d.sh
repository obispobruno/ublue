#!/usr/bin/env bash

set -oue pipefail

cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bak
echo 'assumeyes=True' | tee -a /etc/dnf/dnf.conf

git clone https://github.com/Fred78290/nct6687d
cd nct6687d
make akmod
echo "nct6687" >> /etc/modules
cd ..
rm -rf nct6687d

rm -f /etc/dnf/dnf.conf
mv /etc/dnf/dnf.conf.bak /etc/dnf/dnf.conf
