

output "endpoint" {
    value       = "${join("", google_container_cluster.k8s_cluster.*.endpoint)}"
}
 

output "client_certificate" {
    value       = "${google_container_cluster.k8s_cluster.0.master_auth.0.cluster_ca_certificate}" 
}

output "client_key" {
    value       = "${google_container_cluster.k8s_cluster.0.master_auth.0.client_key}"
}

output "client_ca_certificate" {
    value       = "${google_container_cluster.k8s_cluster.0.master_auth.0.cluster_ca_certificate}"
}










