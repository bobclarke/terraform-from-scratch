data "helm_repository" "brigade" {
    name = "brigade"
    url  = "https://brigadecore.github.io/charts"
}


resource "null_resource" "deps"{
  provisioner "local-exec" {
    command = "echo ${var.tiller_id}"
  }
}

resource "helm_release" "brigade" {
  count      = "${var.enabled}"  
  name       = "brigade"
  namespace  = "brigade"
  repository = "brigade"
  chart      = "${data.helm_repository.brigade.0.name}"

  values = [
    "${file( "${path.module}/config/values.yaml" )}"
  ]

  depends_on = ["null_resource.deps"]
}

variable "enabled" {}
variable "tiller_id" {}