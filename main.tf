
module "kubernetes-cluster" {
  enabled = "1"
  source = "modules/kubernetes_cluster"
  project-name = "terraform-from-scratch"
}

module "helm" {
  enabled = "1"
  source = "modules/helm_setup"
}