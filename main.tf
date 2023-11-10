terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "unauthorized_pod_execution_alert" {
  source    = "./modules/unauthorized_pod_execution_alert"

  providers = {
    shoreline = shoreline
  }
}