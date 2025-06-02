resource "aws_security_group" "discord_bot_sg" {
  name        = "discord-bot-sg"
  description = "Allow SSH and outbound internet for Discord bot"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <-- Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "discord_bot" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = "discord-bot-key"
  vpc_security_group_ids = [aws_security_group.discord_bot_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.discord_bot_profile.name

  user_data = templatefile("${path.module}/discord-bot-userdata.sh.tmpl", {})


  tags = {
    Name = "discord-bot"
  }
}