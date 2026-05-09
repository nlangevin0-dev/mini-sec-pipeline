terraform {
    required_version = ">= 1.5"

    required_providers {
      aws =  {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
      random = {
    source  = "hashicorp/random"
    version = "~> 3.0"
  }

    }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "kafka" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "${var.env}-vpc"
    }
}

resource "aws_subnet" "kafka_sub1" {
    vpc_id = aws_vpc.kafka.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.env}-subnet-1"
    }
}

resource "aws_internet_gateway" "kafka_igw" {
    vpc_id = aws_vpc.kafka.id
    tags = {
        Name = "${var.env}-igw"
    }
}

resource "aws_route_table" "kafka_rt" {
    vpc_id = aws_vpc.kafka.id
   
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.kafka_igw.id
    }
     tags = {
        Name = "${var.env}-route-table"
    }
}

resource "aws_security_group" "kafka_sg" {
    name = "${var.env}-kafka-sg"
    description = "Security group for Kafka cluster"
    vpc_id = aws_vpc.kafka.id

    ingress {
        from_port = 9092
        to_port = 9092
        protocol = "tcp"
        cidr_blocks = ["${var.home_ip}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.home_ip}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_route_table_association" "kafka_rta" {
    subnet_id = aws_subnet.kafka_sub1.id
    route_table_id = aws_route_table.kafka_rt.id
}


data "aws_ami" "amazon_linux_2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

resource "aws_instance" "kafka_broker" {
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.kafka_sub1.id
    key_name = aws_key_pair.kafka_key.key_name
    vpc_security_group_ids = [aws_security_group.kafka_sg.id]
    tags = {
        Name = "${var.env}-kafka-broker"
    }
}

resource "aws_key_pair" "kafka_key" {
    key_name = "${var.env}-kafka-key"
    public_key = file("~/.ssh/id_ed25519.pub")
  
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "events" {
  bucket = "${var.env}-min-sec-pipeline-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.env}-events-bucket"
  }
}

