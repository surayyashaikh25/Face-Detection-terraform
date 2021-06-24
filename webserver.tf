provider "aws"{
	region = "us-east-1"
	profile = "admin"
}

resource "aws_instance" "webos1"{
	ami="ami-0aeeebd8d2ab47354"
	instance_type="t2.micro"
  security_groups = [ "newsg" ]
  key_name = "terraform_key"
	tags={
		Name="TF webserver"
	}

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Asus/Downloads/terraform_key.pem")
    host     = aws_instance.webos1.public_ip
  }

  provisioner "remote-exec" {
    inline = [
	"sudo yum install httpd -y",
	"sudo yum install php -y",
	"sudo systemctl enable httpd --now",
	"sudo mkfs.ext4 /dev/xvdc",
	"sudo  mount /dev/xvdc  /var/www/html",
	"sudo yum install git -y",
	"sudo git clone https://github.com/surayyashaikh25/TestWebPages.git   /var/www/html/web"
    ]
  }
}
resource "aws_ebs_volume" "tfst1"{
	availability_zone= aws_instance.webos1.availability_zone
	size = 1
	tags={
	Name= "New Storage from terraform"
	}
}

resource "aws_volume_attachment" "ebs_attach"{
	device_name = "/dev/sdh"
	volume_id = aws_ebs_volume.tfst1.id
	instance_id = aws_instance.webos1.id
}

