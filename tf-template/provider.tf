provider "kubernetes" {
    host = "${yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.server}"
    client_certificate = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-certificate-data)}"
    client_key = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).users.0.user.client-key-data)}"
    cluster_ca_certificate = "${base64decode(yamldecode(civo_kubernetes_cluster.k8s_demo_1.kubeconfig).clusters.0.cluster.certificate-authority-data)}"
}
