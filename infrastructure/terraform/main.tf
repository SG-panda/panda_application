provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "panda" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t2.micro"
    key_name = "moje_nowe_klucze"

    connection {
        host = self.public_ip
        type = "ssh"
        user = "ubuntu"
        private_key = file("moje_nowe_klucze.pem")
    }

    provisioner "remote-exec" {
        inline = [
            "mkdir -p /home/ubuntu/katalog",
            "echo 123 > /home/ubuntu/katalog/plik",
        ]
    }
}