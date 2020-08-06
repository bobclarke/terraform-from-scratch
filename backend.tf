terraform {
  backend "gcs" {
    bucket                    = "tf-from-scratch-remote-state"
    //prefix                    = "terraform"
    project                   = "tf-from-scratch-remote-state"
    credentials               = "/Users/clarkeb/gcloud/keys/tf-from-scratch-sa.json"
  }
}
