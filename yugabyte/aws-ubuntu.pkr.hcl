packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws-yugabyte"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    Name        = "learn-packer-instance"
    Environment = "development"
  }
}

build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y wget gnupg2 lsb-release python-is-python3",
      "wget https://downloads.yugabyte.com/releases/2024.2.1.0/yugabyte-2024.2.1.0-b185-linux-x86_64.tar.gz",
      "tar xvfz yugabyte-2024.2.1.0-b185-linux-x86_64.tar.gz",
      "cd yugabyte-2024.2.1.0",
      "./bin/post_install.sh",
      "./bin/yugabyted start",
      "./bin/yugabyted status",
      "echo 'Provisioning complete'"
    ]
  }

  provisioner "shell" {
    inline = ["echo 'This is Yugabyte DB setup complete'"]
  }
}

post-processor "local-exec" {
  inline = [
    "echo 'Image successfully created'"
  ]
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}
