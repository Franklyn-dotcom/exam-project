#traefik
# Traefik for the load balancer

resource "kubernetes_namespace" "traefik" {
    
    depends_on = [
        time_sleep.wait_for_kubernetes
    ]

    metadata {
        name = "traefik"
    }
}

resource "helm_release" "traefik" {
    depends_on = [
        kubernetes_namespace.traefik
    ]

    name = "traefik"
    namespace = "traefik"

    repository = "https://helm.traefik.io/traefik"
    chart = "traefik"
    # version = "v20.5.0"

    # Set Traefik as the Default Ingress Controller
    set {
        name  = "ingressClass.enabled"
        value = "true"
    }
    set {
        name  = "ingressClass.isDefaultClass"
        value = "true"
    }
    
    # Default Redirect
    set {
        name  = "ports.web.redirectTo"
        value = "websecure"
    }

    # Enable TLS on Websecure
    set {
        name  = "ports.websecure.tls.enabled"
        value = "true"
    }

    # add the latest helm version
   

}
