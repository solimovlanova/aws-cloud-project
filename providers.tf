terraform {
  cloud {
    organization = "Soli"
    hostname = "app.terraform.io" 

    workspaces {
      name = "aws-cloud-project"
    }
  }
}

provider "aws" {
  region = var.region
}

