

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "vpc-kafka-devl"
  cidr                 = "10.11.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.11.4.0/24", "10.11.5.0/24", "10.11.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "kafka-devl-sg" {
  name        = "kafka-devl-sg"
  description = "kafka-devl-sg"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "kafka-devl-sg"
  }
}

resource "aws_kms_key" "kms" {
  description = "example"
}

resource "aws_msk_cluster" "msk-devl" {
  cluster_name           = "msk-devl"
  kafka_version          = "2.6.2"
  number_of_broker_nodes = 3
  encryption_info        = true

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 100
    client_subnets = [module.vpc.public_subnets]
    security_groups = [aws_security_group.kafka-devl-sg.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  #logging_info {
   # broker_logs {
    #  cloudwatch_logs {
     #   enabled   = true
      #  log_group = aws_cloudwatch_log_group.test.name
      #}
      #firehose {
      #  enabled         = true
      #  delivery_stream = aws_kinesis_firehose_delivery_stream.test_stream.name
      #}
      #s3 {
      #  enabled = true
      #  bucket  = aws_s3_bucket.bucket.id
      #  prefix  = "logs/msk-"
      #}
    #}
  #}

  tags = {
    foo = "msk-devl"
  }
}