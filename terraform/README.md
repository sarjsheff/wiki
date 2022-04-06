### ClusterIssuer

```
resource "kubernetes_manifest" "clusterissuer_letsencrypt" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata"   = {
      "name" = "letsencrypt"
    }
    "spec" = {
      "acme" = {
        "email"               = "sarjsheff@yandex.ru"
        "privateKeySecretRef" = {
          "name" = "letsencrypt"
        }
        "server"  = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            selector = {}
            "http01" = {
              "ingress" = {
                class = "nginx"
              }
            }
          },
        ]
      }
    }
  }
}
```

### Certificate

```
resource "kubernetes_manifest" "host_example_ru" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata   = {
      name      = "host-example-ru"
      namespace = "namespace"
    }
    spec = {
      commonName = "host.example.ru"
      dnsNames   = ["host.example.ru"]
      issuerRef  = {
        group = "cert-manager.io"
        kind  = "ClusterIssuer"
        name  = "letsencrypt"
      }
      secretName = "host-example-ru-tls"
    }
  }
}

```

### Ingress

```
resource "kubernetes_manifest" "http_ingress" {

  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata"   = {
      "name"      = "host-ingress"
      "namespace" = "namespace"
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
      }
    }
    "spec" = {
      "rules" = [
        {
          "host" = "host.example.ru"
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "service" = {
                    "name" = "service-name"
                    "port" = {
                      "number" = 80
                    }
                  }
                }
                "path"     = "/"
                "pathType" = "Prefix"
              },
            ]
          }
        },
      ]
      "tls" = [
        {
          "hosts" = [
            "host.example.ru",
          ]
          "secretName" = "host-example-ru-tls"
        },
      ]
    }
  }
}

```
