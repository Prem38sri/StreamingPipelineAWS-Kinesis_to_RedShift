provider "aws" {
  region = "us-east-1"
  access_key  = "****"
  secret_key = "*******"
}

resource "aws_iam_role" "StreamPOCIAM_TE" {
  name = "StreamPOC_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "StreamPOC_policy" {
  name = "StreamPOC_policy"
  role = aws_iam_role.StreamPOCIAM_TE.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "kinesis:*",
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  role       = aws_iam_role.StreamPOCIAM_TE.id
  count      = "${length(var.iam_policy_arn)}"
  policy_arn = "${var.iam_policy_arn[count.index]}"
}


resource "aws_iam_instance_profile" "StreamPOCInstance_profile" {
  name = "StreamPOCInstance_profile"
  role = aws_iam_role.StreamPOCIAM_TE.name
}


resource "aws_instance" "ec2_spark_engine" {
  ami           = "ami-0dc2d3e4c0f9ebd18"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.StreamPOCInstance_profile.name

  tags = {
    Name = "StreamPOC"
  }
}

resource "aws_kinesis_stream" "test_stream" {
  name             = "terraform-kinesis-test"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "test"
  }
}

resource "aws_redshift_cluster" "StreamPOC_RShift" {
  cluster_identifier = "tf-redshift-cluster"
  database_name      = "mydb"
  master_username    = "myrsuser"
  master_password    = "Password%1"
  node_type          = "dc1.large"
  cluster_type       = "single-node"
}

