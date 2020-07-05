
data "terraform_remote_state" "rs" {
  backend = "gcs"
  config = {
    bucket                    = "${var.project-name}-remote-state"
    prefix                    = "terraform"
    project                   = "${var.project-name}"
    credentials               = "/Users/clarkeb/gcloud/keys/${var.project-name}-sa.json"
  }
}

provider "helm" {
  //service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  service_account = "tiller"
  kubernetes {
    host                    = "${format( "https://%s", "${data.terraform_remote_state.rs.k8s_endpoint}" ) }"
    //client_certificate      = "${data.terraform_remote_state.rs.k8s_client_certificate}"
    //client_key              = "${data.terraform_remote_state.rs.k8s_client_key}"
    //cluster_ca_certificate  = "${data.terraform_remote_state.rs.k8s_client_ca_certificate}"
  }
}

provider "google" {
  project                     = "kitchen-terraform"
  region                      = "europe-west2"
  zone                        = "europe-west2-a"
  credentials                 = "${file("/Users/clarkeb/gcloud/keys/kitchen-terraform-sa.json")}"
}

