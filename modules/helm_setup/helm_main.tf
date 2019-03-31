
// Create a service account for tiller 
resource "kubernetes_service_account" "tiller" {
  count = "${var.enabled}"
  metadata {
    name = "tiller"
    namespace  = "${kubernetes_secret.tiller-sa-secret.metadata.0.namespace}"
  }
  secret {
    name       = "${kubernetes_secret.tiller-sa-secret.metadata.0.name}"
  }
}

resource "kubernetes_secret" "tiller-sa-secret" {
  count = "${var.enabled}"
  metadata {
    name = "tiller-sa"
    namespace = "kube-system"
  }
}

//provider "helm" {
//
//  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
// 
//  kubernetes {
//    host     = "https://104.196.242.174"
//    client_certificate     = "${file("~/.kube/client-cert.pem")}"
//    client_key             = "${file("~/.kube/client-key.pem")}"
//    cluster_ca_certificate = "${file("~/.kube/cluster-ca-cert.pem")}"
//  }
//}