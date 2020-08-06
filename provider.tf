provider "google" {
  project                     = "tf-from-scratch"
  region                      = "europe-west2"
  zone                        = "europe-west2-a"
  credentials                 = "${file("/Users/clarkeb/gcloud/keys/tf-from-scratch-sa.json")}"
}
