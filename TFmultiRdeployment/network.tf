#create vpc in us-west-2
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name = "master-vpc-jenkins"
  }
}


#create vpc in us-west-1
resource "aws_vpc" "vpc_master_NCA" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name = "worker-vpc-jenkins"
  }
}

#create IGW in us-west-2
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id

}

#create IGW in us-west-1
resource "aws_internet_gateway" "igw-NCA" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_NCA.id
}


#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

#create subnet # 1 in us-west-2
resource "aws_subnet" "subnet1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"

}


#create subnet # 1 in us-west-2
resource "aws_subnet" "subnet2" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
}


#create subnet # 1 in us-west-1
resource "aws_subnet" "subnet1_NCA" {
  provider   = aws.region-worker
  vpc_id     = aws_vpc.vpc_master_NCA.id
  cidr_block = "192.168.1.0/24"
}


#Initiate peering connection request from us-west-2
resource "aws_vpc_peering_connection" "uswest2-uswest1" {
  provider    = aws.region-master
  peer_vpc_id = aws_vpc.vpc_master_NCA.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region-worker

}

#Accept vpc peering request in us-west-1 from us-west-2
resource "aws_vpc_peering_connection_accepter" "accepter_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.uswest2-uswest1.id
  auto_accept               = true
}



#create route table in us-west-2
resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.uswest2-uswest1.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "master-region-RT"
  }
}

#overwrite default route table of vpc(master) with our route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}



#create route table in us-west-1
resource "aws_route_table" "internet_route-NCA" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_NCA.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-NCA.id
  }

  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.uswest2-uswest1.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "worker-region-RT"
  }
}


#overwrite default route table of vpc(worker) with our route table entries
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.vpc_master_NCA.id
  route_table_id = aws_route_table.internet_route-NCA.id
}