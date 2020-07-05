terraform {
  backend "gcs" {
    bucket                    = "kitchen-terraform-remote-state"
    prefix                    = "terraform"
    project                   = "kitchen-terraform"
    credentials               = "/Users/clarkeb/gcloud/keys/kitchen-terraform-sa.json"
  }
}
