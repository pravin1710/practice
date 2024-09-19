
variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "aws_cloudwatch_retention_in_days" {
  type        = number
  description = "AWS CloudWatch Logs Retention in Days"
  default     = 5
}

variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "Lead"
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
  default     = "Stag"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.11.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets"
  default     = ["10.11.100.0/24", "10.11.101.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets"
  default     = ["10.11.0.0/24", "10.11.1.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "route53_zone_id" {
  type        = string
  description = "route53_zone_id"
  default     = "Z01756442O5YBGHD3SZ2"
}

variable "bucket_name" {
  type        = string
  default     = "leadsigma-terraform-state.tfstate"
  description = "backend bucket for state file"
}

variable "bucket_key" {
  default     = "stateterraform_state.tfstate"
  description = "key value for backend bucket"

}

variable "domain_name" {
  description = "route_53 domain name"
  default     = "stg-leadsigma.com"

}
variable "aws_account_id" {
  description = "account id"
  default     = "654654285718"
}

variable "service-1" {
  description = "name for langchain-chatbot ecs service"
  default     = "langchain-chatbot"
}

variable "service-2" {
  description = "name for langchain-chatbot ecs service"
  default     = "calendar"
}

variable "certificate_arn" {
  description = "ssl certificate arn"
  default     = "arn:aws:acm:us-east-1:590183913538:certificate/b0d90e57-17a0-4530-9872-ae915c44c7f3"
}


variable "Calendar_client_id" {
  description = "calendar_client_id"
  default     = "7q1d1v0bhnnthbu93u6smv7ku2"
}

variable "Calendar_client_secret" {
  description = "calendar_client_secret"
  default     = "1rgeul7pdo0uscq4qvo0coneda69kdk16l4lail09scjj00ovqn0"
}

variable "Newrelic_key" {
  description = "newrelic_key"
  default     = "1af6a44bd5b06dfda1eb2dfbfedf0b241b4bNRAL"
}

variable "rds_hostname" {
  description = "Hostname of database"
  default     = "calendar-service.c7i6uuygizsp.us-east-1.rds.amazonaws.com"
}

variable "auth_uri" {
  description = "AUTH-URI"
  default     = "https://auth.stagingleadsigma.com"
}

variable "calendar-scope" {
  description = "value for calendar-scope"
  default     = "https://messaging-service.stagingleadsigma.com/teams"
}

variable "rds_username" {
  description = "calendar-service database username"
  default     = "calendar-1"
}

variable "rds_password" {
  description = "calendar-service database password"
  default     = "555gochiefs282721!"
}

variable "access_key_id" {
  description = "aws_access_key_id"
  default     = "WA4w6zTwRhSy8Sa+Lc2flvIwEKDXlG1RxNqTNh7U"
}

variable "secret_access_key_id" {
  description = "aws_secrets_access_key_id"
  default     = "WA4w6zTwRhSy8Sa+Lc2flvIwEKDXlG1RxNqTNh7U"
}
variable "versioning_enabled" {
  default     = true
  description = " Bollean value indicating if versionig for objects within bucket needs to be enabled. Default is true."
}
variable "lifecycle_enabled" {
  default     = true
  description = "Does this bucket needs any oject to either transtion to another low cost storage or needs object to be expired after some days"
}
variable "logging" {
  default     = true
  description = "Bucket access logging configuration is required for the created bucket. Since the log buckect needs to be created before actual bucket enabling this option created logs in same bucket with log prefix."
}
variable "env" {
  type    = string
  default = "dev"
}
variable "tags" {
  type = map(any)
  default = {
    account = "dev"
    owner   = "jaffar"
  }
}

variable "bucket" {
  default     = "buckgrafana"
  description = "The name of the bucket to create. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix."
  type        = string
}
variable "s3_id" {
  default     = "logs"
  type        = string
  description = "provide the ID , this can be any meanigful name for us to identify the liefcle policy applied to Bucket"
}

##  This option enables the bucket object to transition to another lowcost storage ##
variable "enable_transition" {
  default     = true
  description = "(Optional) Information in regards to moving the data to low cost storage is required"
}
variable "s3_transition_days" {
  type        = number
  default     = 30
  description = "if the trasition is enabled . How long before it moves to low cost storage"
}
variable "s3_transition_storage_class" {
  type        = string
  default     = "ONEZONE_IA"
  description = "if the transition is enabled . which storage it needs to move, possible options are IA_storage, Glacier"
}

variable "key_spec" {
  default = "SYMMETRIC_DEFAULT"
}

variable "enabled" {
  default = true
}

variable "rotation_enabled" {
  default = true
}





