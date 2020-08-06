

// Create a secret for the Tiller service account 
resource "kubernetes_secret" "tiller-sa-secret" {
  count         = "${var.enabled}"
  metadata {
    name        = "tiller-sa"
    namespace   = "kube-system"
  }
}


// Create a service account for Tiller 
resource "kubernetes_service_account" "tiller" {
  count         = "${var.enabled}"
  metadata {
    name        = "tiller"
    namespace   = "${kubernetes_secret.tiller-sa-secret.metadata.0.namespace}"
  }
  secret {
    name        = "${kubernetes_secret.tiller-sa-secret.metadata.0.name}"
  }
}

// Assign cluster-admin to Tiller 
resource "kubernetes_cluster_role_binding" "tiller-binding" {
  count         = "${var.enabled}"
  metadata {
      name = "tiller-binding"
  }
  role_ref {
      api_group = "rbac.authorization.k8s.io"
      kind = "ClusterRole"
      name = "cluster-admin"
  }
  subject {
      kind = "User"
      name = "admin"
      api_group = "rbac.authorization.k8s.io"
  }
  subject {
      kind = "ServiceAccount"
      name = "tiller"
      namespace = "kube-system"
  }
  subject {
      kind = "Group"
      name = "system:masters"
      api_group = "rbac.authorization.k8s.io"
  }
}

data "terraform_remote_state" "rs" {
  count = "${var.enabled}"
  backend = "gcs"
  config = {
    bucket                    = "tf-from-scratch-remote-state"
    //prefix                    = "terraform"
    project                   = "tf-from-scratch"
    credentials               = "/Users/clarkeb/gcloud/keys/tf-from-scratch-sa.json"
  }
}

provider "helm" {
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
 
  kubernetes {
  host       = "${concat( "https://", "${data.terraform_remote_state.rs.outputs.k8s_endpoint}" ) }"
  client_certificate      = "${data.terraform_remote_state.rs.outputs.k8s_client_certificate}"
  client_key              = "${data.terraform_remote_state.rs.outputs.k8s_client_key}"
  cluster_ca_certificate  = "${data.terraform_remote_state.rs.outputs.k8s_client_ca_certificate}"
  }
}