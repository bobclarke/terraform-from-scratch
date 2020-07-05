
resource null_resource "deps" {
  provisioner "local-exec" {
    command = "echo ${var.k8s-cluster-id}"
  }
}


// Create a secret for the Tiller service account 
resource "kubernetes_secret" "tiller-sa-secret" {
  count         = "${var.enabled}"
  metadata {
    name        = "tiller-sa"
    namespace   = "kube-system"
  }
  depends_on    = ["null_resource.deps"]
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
      name = "${kubernetes_service_account.tiller.metadata.0.name}"
      namespace = "kube-system"
  }
  subject {
      kind = "Group"
      name = "system:masters"
      api_group = "rbac.authorization.k8s.io"
  }
}

output "tiller_id" {
  value = "${join("", kubernetes_cluster_role_binding.tiller-binding.*.id )}"
}
