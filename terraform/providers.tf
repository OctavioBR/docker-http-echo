terraform {
  required_version = "~> 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    region = "eu-west-2"
    bucket = "097614841487-tfstate"
    key    = "docker-http-echo.tfstate"
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Repository = "github.com/octaviobr/docker-http-echo"
      Managed_by = "terraform"
    }
  }
}
