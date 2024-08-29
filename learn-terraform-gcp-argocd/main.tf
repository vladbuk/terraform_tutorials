terraform { 
  cloud { 
    organization = "vladbuk-inc" 
    workspaces { 
      name = "learning-gcp-argocd" 
    } 
  } 
}

provider "google" {
  project = "kuber-430607"
  region  = "us-east1"
  zone    = "us-east1-b"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "k8s"
}

variable "cluster_location" {
  description = "The location of the GKE cluster"
  type        = string
  default     = "us-east1-b"
}

variable "chart_version" {
  description = "Helm Chart Version of ArgoCD: https://github.com/argoproj/argo-helm/releases"
  type        = string
  default     = "7.4.4"
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.cluster_location
}


provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.primary.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = true
  namespace        = "argocd"

  # set {
  #   name  = "server.service.type"
  #   value = "LoadBalancer"
  # }
}


# output "argocd_url" {
#   description = "The URL to access ArgoCD"
#   value       = helm_release.argocd.status[0].load_balancer[0].ingress[0].hostname
# }

output "argocd_version" {
  value = helm_release.argocd.metadata[0].app_version
}

output "helm_revision" {
  value = helm_release.argocd.metadata[0].revision
}

output "chart_version" {
  value = helm_release.argocd.metadata[0].version
}