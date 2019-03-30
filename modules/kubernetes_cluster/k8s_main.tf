resource "google_container_cluster" "k8s_cluster" {
  count              = "1"
  name               = "terraform-from-scratch-k8s-cluster"
  zone               = "europe-west2-a"
  initial_node_count = "3" 
  project            = "terraform-from-scratch"

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}