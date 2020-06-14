provider "aws" {
    region = "us-east-2"
    version = "~> 2.66"
}

variable "server_port" {
    description = "Server Port used for HTTP Requests"
    type = number
    default = 8080
}

resource "aws_instance" "ut-example" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ut-instance.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohub busybox httpd -f -p ${var.server_port} &
                EOF

    tags = {
        Name = "ut-terraform-example"
    }
}

resource "aws_security_group" "ut-instance" {
    name = "ut-terraform-example-instance"

    tags = {
        Name = "ut-terraform-example-instance-sg"
    }

    ingress {
        from_port = var.server_port 
        to_port = var.server_port 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
    value = aws_instance.ut-example.public_ip
    description = "Public IP of the AWS EC2 instance"

}