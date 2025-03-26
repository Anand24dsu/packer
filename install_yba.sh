#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt update -y && sudo apt upgrade -y
wget https://downloads.yugabyte.com/releases/2024.2.1.0/yba_installer_full-2024.2.1.0-b185-linux-x86_64.tar.gz
tar -xf yba_installer_full-2024.2.1.0-b185-linux-x86_64.tar.gz
sudo mkdir -p /opt/yba-ctl/
touch yba.lic
echo 'eyJJRCI6ImN0cm1tMzA1aDVhczcydnZua2YwIiwiY3VzdG9tZXIiOiJBcnVzIiwiY3VzdG9tZXJfZW1haWxzIjpbImp1bGlldC5wQGFydXMuY28uaW4iXSwicHVycG9zZSI6MCwiZXhwaXJhdGlvbl90aW1lIjoiMjAyNS0wNC0wNCIsImNyZWF0ZV90aW1lIjoiMjAyNS0wMS0wMyJ9:MEUCIQCpf7GOOfWg0XmddS0rU6bjLoPEFmE7m3J2LmkLJgyjswIgfK+pIjDe07Fdb3uSM2kbBbrjjeP4Z1McDFtUCEQdj9k=' > yba.lic
sudo mv yba.lic /opt/yba-ctl/
cd yba_installer_full-2024.2.1.0-b185/
yes | sudo -E ./yba-ctl preflight
yes | sudo -E ./yba-ctl install -l /opt/yba-ctl/yba.lic
sudo yba-ctl status
echo 'Successfully Installed Yugabyte Anywhere, VM is now READY to use!'