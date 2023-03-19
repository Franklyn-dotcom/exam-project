resource "kubernetes_ingress_v1" "micro-ingress" {
  metadata {
    name      = "sock-shop"
    namespace = "sock-shop"
    labels = {
      name = "front-end"
    }

  }

  spec {
    rule {
      host = "sock-shop.mbanugo.bulgogi174.messwithdns.com"
      http {
        path {
          backend {
            service{
              name = "front-end"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}



resource "kubernetes_ingress_v1" "portfolio-ingress" {
  metadata {
    name      = "web-app"
    labels = {
      name = "web-app"
    }
    
  }

  spec {
    rule {
      host = "web-app.mbanugo.bulgogi174.messwithdns.com"
      http {
        path {
          backend {
            service{
              name = "postgres"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
