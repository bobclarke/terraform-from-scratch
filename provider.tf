provider "google" {
  project                     = "terraform-from-scratch"
  region                      = "europe-west2"
  zone                        = "europe-west2-a"
  credentials                 = "${file("/Users/clarkeb/gcloud/keys/terraform-from-scratch-sa.json")}"
}