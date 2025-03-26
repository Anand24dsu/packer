packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
 
variable "region" {
  type    = string
  default = "us-west-2"
}
 
variable "instance_type" {
  type    = string
  default = "c5a.xlarge"
}
 
variable "source_ami" {
  type    = string
  default = "ami-00c257e12d6828491"
}
 
source "amazon-ebs" "yugabytedb" {
  region                      = var.region
  instance_type               = var.instance_type
  source_ami                  = var.source_ami
  ssh_username                = "ubuntu"
  ami_name                    = "yugabytedb-ami-{{timestamp}}"
  associate_public_ip_address = true
 
  tags = {
    Name         = "Latest_Yugabyte_Anywhere_AMI"
    Architecture = "x86_64"
  }
 
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 250
    volume_type = "gp3"
    delete_on_termination = true
  }
}
 
build {
  sources = ["source.amazon-ebs.yugabytedb"]
 
  provisioner "file" {
    content     = <<EOF
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
  EOF
    destination = "/tmp/install_yba.sh"
  }
 
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_yba.sh",
      "sudo /tmp/install_yba.sh"
    ]
  }
}