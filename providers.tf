terraform {
  cloud {
    organization = "Soli"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-cloud-project"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "random" {}
