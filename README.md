# terraform-from-scratch

## pre reqs:
* A GCP account
* Terraform v0.11.11
* gcloud CLI
* kubectl 

## Set up GCP project and service account:
In the GCP console create a new Google project
Then login with the cloud CLI:
```
gcloud auth login
```
Switch to your newly created project:
```
gcloud config set project your-gcp-project
```

Create a service account:
```
gcloud iam service-accounts create your-gcp-project-sa
```

Link this service account to your project:
```
gcloud projects add-iam-policy-binding your-terraform-project \
  --member “serviceAccount:your-gcp-project-sa@your-gcp-project.iam.gserviceaccount.com" \
  --role "roles/owner"
```  

Create and download a private key for this service account (Terraform will use this to authenticate to your gcp project):
```
gcloud iam service-accounts keys create “/path/you/choose/your-terraform-project-sa.json" \
   --iam-account "your-gcp-project-sa@your-gcp-project.iam.gserviceaccount.com"
```

## Set up backend for remote terraform state 
Create a bucket to store terraform state:
```
gsutil mb -l eu gs://your-gcp-project-remote-state
```

Create a file named backend.tf and add the following to set up the google terraform provider:
```
terraform {
  backend "gcs" {
    bucket                    = "your-gcp-project-remote-state"
    prefix                    = "terraform"
    project                   = "your-gcp-project"
    credentials               = "/path/you/choose/your-gcp-project-sa.json"
  }
}
```

Initialise the backend:
```
terraform init
```

Check that the remote state has been initialised (note - we’re not using workspaces yet therefore we’re working in the default workspace):
```
gsutil cat gs://your-gcp-project-remote-state/terraform/default.tfstate
```

This resulting display should be something similar to:
```
{
    "version": 3,
    "serial": 1,
    "lineage": "2c1eae35-87b7-8d2a-556a-09ab57d0bff7",
    "modules": [
        {
            "path": [
                "root"
            ],
            "outputs": {},
            "resources": {},
            "depends_on": []
        }
    ]
}
```


## Set up the Google provider
Create a file named providers.tf with the following contents:
```
provider "google" {
  project                     = “your-gap-project"
  region                      = "europe-west2"
  zone                        = "europe-west2-a"
  credentials                 = "${file(“/path/you/choose/your-gcp-project-sa.json")}"
}
```

Initialise the provider:
```
terraform init
```

## Enable the container.googleapis.com API Service 
```
gcloud services enable container.googleapis.com
```

We’re now ready to start building stuff - let’s use terraform modules to do this as they are pretty cool 

## Create your first Terraform module
Create a directory called modules and under here create a directory called kubernetes_cluster (yes - we’re going to write a module to deploy a k8s cluster 🙂)
cd to modules/kubernetes_cluster and create a file named k8s_main.tf:
```
mkdir -p modules/kubernetes_cluster
cd modules/kubernetes_cluster
touch k8s_main.tf
```

Add the following contents to  k8s_main.tf (Notice we’re not using any variables at the moment, this will come later)
```
resource "google_container_cluster" "k8s_cluster" {
  count              = "1"
  name               = "terraform-from-scratch-k8s-cluster"
  zone               = "europe-west2-a"
  initial_node_count = "3" 
  project            = "tf-from-scratch"


  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
```

Now we need to call this module. To do this cd back up to your top level directory (where backend.tf and providers.tf reside) and create main.tf with the following contents:
```
module "kubernetes-cluster" {
  source = "modules/kubernetes_cluster"
}
```

Initialise the new module:
```
terraform init
```

Plan the build 
```
terraform plan
```

If all looks well, run the build:
```
terraform apply -auto-approve
```

Update ~/.kube/config and set context to your new kubernetes cluster:
```
gcloud container clusters get-credentials your-gcp-project-k8s-cluster
```

Check connectivity:
```
kubectl get pods -n kube-system
```

