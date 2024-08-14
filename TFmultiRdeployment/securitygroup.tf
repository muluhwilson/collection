#create SG for LB,only TCP/80,TCP/443 and outbound access
resource "aws_security_group" "lb-sg" {
  provider    = aws.region-master
  name        = "lb-sg"
  description = "Allow 443 traffic to jenkins SG"
  vpc_id      = aws_vpc.vpc_master.id

  ingress {
    description = "allow 443 traffic from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow 80 traffic from anywhere for redirection"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb-sg"
  }
}


#create SG for Jenkins master for allowing TCP/8080from * and TCP/22 from your IP in us-west-2
resource "aws_security_group" "jenkins-sg" {
  provider    = aws.region-master
  name        = "jenkins-sg"
  description = "Allow TCP/8080 and TCP/22"
  vpc_id      = aws_vpc.vpc_master.id

  ingress {
    description = "allow 22 from our public ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }

  ingress {
    description     = "allow anyone on port 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }

  ingress {
    description = "allow traffic from us-west-1"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



#create SG for worker for allowing TCP/22 from your IP in us-west-1
resource "aws_security_group" "jenkins-sg-NCA" {
  provider    = aws.region-worker
  name        = "jenkins-NCA"
  description = "Allow TCP/8080 and TCP/22"
  vpc_id      = aws_vpc.vpc_master_NCA.id

  ingress {
    description = "allow 22 from our public ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }


  ingress {
    description = "allow traffic from us-west-2"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
