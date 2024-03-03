# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "REGION" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}
variable "DB_PASSWORD" {
  type    = string
  default = "awsbackup133"
}