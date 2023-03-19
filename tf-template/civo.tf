#civo 
terraform {
    
    required_version = ">= 0.13.0"

    required_providers {
        civo = {
            source = "civo/civo"
            version = "~> 1.0.13"
        }

        helm = {
            source = "hashicorp/helm"
            version = "2.9.0"
        }

        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "2.8.0"     
        }

        kubectl = {
            source = "gavinbunney/kubectl"
            version = "1.13.1"
        }
    }
}

provider "civo" {
    token = var.civo-token
    region = "FRA1"
}


# Kubernetes Cluster

data "civo_size" "medium" {

    # TODO: (optional): change the values according to your desired instance image sizing
    # ---
    filter {
        key = "name"
        values = ["g4s.kube.medium"]
        match_by = "re"
    }

}


resource "civo_kubernetes_cluster" "k8s_demo_1" {
  name       = "my-k8s-cluster"
  applications = ""
  firewall_id = civo_firewall.fw_project.id
  num_target_nodes = 3
  pools {
    node_count = 3
    size = element(data.civo_size.medium.sizes, 0).name
  }
}




resource "civo_firewall" "fw_project" {
    name = "fw_project"
}

resource "civo_firewall_rule" "kubernetes_http" {
    firewall_id = civo_firewall.fw_project.id
    protocol = "tcp"
    start_port = "80"
    end_port = "80"
    cidr = ["0.0.0.0/0"]
    direction = "ingress"
    action = "allow"
    label = "kubernetes_http"
}

resource "civo_firewall_rule" "kubernetes_https" {
    firewall_id = civo_firewall.fw_project.id
    protocol = "tcp"
    start_port = "443"
    end_port = "443"
    cidr = ["0.0.0.0/0"]
    direction = "ingress"
    action = "allow"
    label = "kubernetes_https"
}

resource "civo_firewall_rule" "kubernetes_api" {
    firewall_id = civo_firewall.fw_project.id
    protocol = "tcp"
    start_port = "6443"
    end_port = "6443"
    cidr = ["0.0.0.0/0"]
    direction = "ingress"
    action = "allow"
    label = "kubernetes_api"
}

provider "helm" {
    kubernetes {
       host = "${yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.server}"
        client_certificate = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-certificate-data)}"
        client_key = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-key-data)}"
        cluster_ca_certificate ="${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.certificate-authority-data)}"
    }
}

#provider "kubernetes" {
#    host = "${yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.server}"
#    client_certificate = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-certificate-data)}"
#    client_key = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-key-data)}"
#    cluster_ca_certificate = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.certificate-authority-data)}"
#    exec {
#    api_version = "client.authentication.k8s.io/v1beta1"
#    args        = ["civo", "get-token", "--cluster-name", "my-k8s-cluster"]
#    command     = "civo"
#  }
#}

provider "kubectl" {
    host = "${yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.server}"
    client_certificate = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-certificate-data)}"
    client_key = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-key-data)}"
    cluster_ca_certificate = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.certificate-authority-data)}"
    config_path = "~/.kube/config"
    load_config_file = false
}

#time used while creating the project
resource "time_sleep" "wait_for_kubernetes" {

    depends_on = [
        civo_kubernetes_cluster.k8s_demo_1
    ]

    create_duration = "20s"
}

# data  "civo_loadbalancer" "traefik-lb" {
#     depends_on = [
#         helm_release.traefik
#     ]
#     name = "demo-kube-system-traefik"
# }

# output "civo_loadbalancer_output" {
#     value = data.civo_loadbalancer.traefik-lb.public_ip
# }
