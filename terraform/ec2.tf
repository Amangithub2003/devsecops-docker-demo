data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.app_name}-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH (Jenkins deploy access)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "App"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Monitoring/observability UIs — restrict these in real use
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
    description = "Grafana"
  }
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
    description = "Kibana"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  # Installs Docker + docker-compose on first boot.
  # Jenkins later scp's docker-compose.yml + configs here and runs
  # `docker compose up -d` over SSH (see deploy/deploy.sh).
  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y docker.io docker-compose-plugin
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu
  EOF

  tags = {
    Name = var.app_name
  }
}
