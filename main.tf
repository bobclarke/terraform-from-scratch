module "kubernetes-cluster" {
  enabled         = "1"
  source          = "modules/kubernetes_cluster"  
  project-name    = "${var.project-name}"
}

module "helm" {
  enabled         = "0"
  source          = "modules/helm_setup"
  project-name    = "${var.project-name}"
  k8s-cluster-id  = "${module.kubernetes-cluster.id}"
}

module "brigade" {
  enabled         = "0"
  source          = "modules/brigade"
  tiller_id       = "${module.helm.tiller_id}"
}


// Outputs for root module (Needed for datasources to work)
output "k8s_endpoint" {
    value       = "${module.kubernetes-cluster.endpoint}"
}

output "k8s_client_certificate" {
    value       = "${module.kubernetes-cluster.client_certificate}"
}

output "k8s_client_key" {
    value       = "${module.kubernetes-cluster.client_key}"
}

output "k8s_client_ca_certificate" {
    value       = "${module.kubernetes-cluster.client_ca_certificate}"
}

