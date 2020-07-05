variable project-name {
  default         = "kitchen-terraform"
}

variable gcp-services {
  default 				= 
    [
      "cloudresourcemanager.googleapis.com",
      "cloudbuild.googleapis.com",
      "cloudbilling.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "iamcredentials.googleapis.com",
      "serviceusage.googleapis.com",
      "bigquery-json.googleapis.com",
      "cloudapis.googleapis.com",
      "clouddebugger.googleapis.com",
      "cloudtrace.googleapis.com",
      "compute.googleapis.com",
      "container.googleapis.com",
      "containerregistry.googleapis.com",
      "datastore.googleapis.com",
      "deploymentmanager.googleapis.com",
      "dns.googleapis.com",
      "logging.googleapis.com",
      "monitoring.googleapis.com",
      "oslogin.googleapis.com",
      "pubsub.googleapis.com",
      "redis.googleapis.com",
      "replicapool.googleapis.com",
      "replicapoolupdater.googleapis.com",
      "resourceviews.googleapis.com",
      "servicemanagement.googleapis.com",
      "sourcerepo.googleapis.com",
      "sql-component.googleapis.com",
      "storage-api.googleapis.com",
      "storage-component.googleapis.com",
      "sqladmin.googleapis.com"
    ]
}
