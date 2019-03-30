terraform {
  backend "gcs" {
    bucket                    = "terraform-from-scratch-remote-state"
    prefix                    = "terraform"
    project                   = "terraform-from-scratch-remote-state"
    credentials               = "/Users/clarkeb/gcloud/keys/terraform-from-scratch-sa.json"
  }
}
