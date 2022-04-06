## Certificate

```
resource "kubernetes_manifest" "host_example_ru" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata   = {
      name      = "host-example-ru"
      namespace = "minio"
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
