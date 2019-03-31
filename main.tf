
module "kubernetes-cluster" {
  enabled         = "1"
  source          = "modules/kubernetes_cluster"  
  project-name    = "${var.project-name}"
}

module "helm" {
  enabled         = "1"
  source          = "modules/helm_setup"
}