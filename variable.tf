variable "iam_policy_arn" {
  description = "IAM Policy to be attached to role test"
  default = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  type = list
}