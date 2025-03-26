variable "instance_type" {
  type    = string
  default = "c5a.xlarge"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "source_ami" {
  type    = string
  default = "ami-00c257e12d6828491"
}

variable "timestamp" {
  default = formatdate("YYYYMMDDHHmmss", timestamp())
}

source "amazon-ebs" "yugabyte" {
  ami_name                    = "yugabytedb-ami-${var.timestamp}"
  associate_public_ip_address = true
  instance_type               = var.instance_type
  region                      = var.region
  source_ami                  = var.source_ami
  ssh_username                = "ubuntu"

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 250
    volume_type           = "gp3"
  }

  tags = {
    Architecture = "x86_64"
    Name         = "Latest_Yugabyte_Anywhere_AMI"
  }
}

build {
  sources = ["source.amazon-ebs.yugabyte"]

  provisioner "file" {
    source      = "install_yba.sh"
    destination = "/tmp/install_yba.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_yba.sh",
      "sudo /tmp/install_yba.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'This is Yugabyte DB setup complete'"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "echo 'Image successfully created'"
    ]
  }
}
