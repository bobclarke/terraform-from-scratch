# terraform-from-scratch

## pre reqs:
* A GCP account
* Terraform v0.11.11
* gcloud CLI
* kubectl 

## Set up GCP project and service account:
Login:
```
gcloud auth login <google email address>
```

Create a new GCP project
```
gcloud projects create your-project-name
```

Switch to the new project you just created (this doesn't happpen by default)
```
gcloud config set project your-project-name
```

Link the new project to your billing account:
```
gcloud beta billing projects link kitchen-terraform --billing-account=your-billing-account-id
```

Create a service account:
```
gcloud iam service-accounts create your-project-name-sa
```

Link this service account to your project:
```
gcloud projects add-iam-policy-binding your-project-name \
  --member “serviceAccount:your-project-name-sa@your-project-name.iam.gserviceaccount.com" \
  --role "roles/owner"
```  

Create and download a private key for this service account (Terraform will use this to authenticate to your gcp project):
```
gcloud iam service-accounts keys create “/path/you/choose/your-project-name-sa.json" \
   --iam-account "your-project-name-sa@your-project-name.iam.gserviceaccount.com"
```

## Set up backend for remote terraform state 
Create a bucket to store terraform state:
```
gsutil mb -l eu gs://your-project-name-remote-state
```

Create a file named backend.tf and add the following to set up the google terraform provider:
```
terraform {
  backend "gcs" {
    bucket                    = "your-project-name-remote-state"
    prefix                    = "terraform"
    project                   = "your-project-name"
    credentials               = "/path/you/choose/your-project-name-sa.json"
  }
}
```

Initialise the backend:
```
terraform init
```

Check that the remote state has been initialised (note - we’re not using workspaces yet therefore we’re working in the default workspace):
```
gsutil cat gs://your-project-name-remote-state/terraform/default.tfstate
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
  project                     = “your-project-name"
  region                      = "europe-west2"
  zone                        = "europe-west2-a"
  credentials                 = "${file(“/path/you/choose/your-project-name-sa.json")}"
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
  name               = "your-project-name-k8s-cluster"
  zone               = "europe-west2-a"
  initial_node_count = "3" 
  project            = "your-project-name"


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
gcloud container clusters get-credentials your-project-name-k8s-cluster
```

Check connectivity:
```
kubectl get pods -n kube-system
```


