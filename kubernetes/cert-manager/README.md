## cert-manager

```
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.0/cert-manager.yaml
```

## Автоматический выпуск (и дальнейший перевыпуск) сертификата letsencrypt с проверкой по HTTP

Настройка выпускающего центра сертификации letsencrypt и выпуск сертификата для домена sdmx.aisa.ru в локальном неймспейсе (для настройки глобального центра сертификации letsencrypt нужно создать ресурс IssuerCluster). Можно не создавать Certificate, он будет создан автоматически для домена указанного в ingress если будет установленная аннотация cert-manager.io/issuer с ссылкой на Issuer:

```
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod
  namespace: test
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: sarj@aisa.ru
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - selector: {}
      http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: sdmx-aisa-ru
  namespace: test
spec:
  secretName: sdmx-aisa-ru-tls
  issuerRef:
    name: letsencrypt-staging
  commonName: sdmx.aisa.ru
  dnsNames:
  - sdmx.aisa.ru
```

Можно принудительно перевыпустить сертификат если стереть secret c ключами sdmx-aisa-ru-tls.

## Использование

Настройка ingress:

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-nginx-ingress
  namespace: test
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    cert-manager.io/issuer: "letsencrypt-prod"          # Ссылка на Issuer
spec:
  tls:                                                  # TLS блок
  - hosts:
    - sdmx.aisa.ru
    secretName: sdmx-aisa-ru-tls                        # Ссылка на secret в котором хранятся выпущенные сертификаты (указывается в Certificate spec.secretName )
  rules:
  - host: sdmx.aisa.ru
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: test-nginx-service
              port:
                number: 80
```

## Выпуск сертификата через DNS

```
helm repo add cert-manager-webhook-pdns https://zachomedia.github.io/cert-manager-webhook-pdns
helm install cert-manager-webhook-pdns cert-manager-webhook-pdns/cert-manager-webhook-pdns
```

```
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns
spec:
  acme:
    email: you@email.com
    preferredChain: ""
    privateKeySecretRef:
      name: letsencrypt-dns
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - dns01:
        webhook:
          config:
            apiUrl: https://api.youpowerdns.com
            secretName: pdns-secret
            zoneName: example.com.
          groupName: acme.yourdomain.tld
          solverName: pdns
---
apiVersion: v1
kind: Secret
metadata:
  name: pdns-secret
  namespace: cert-manager
data:
  api-key: <base64 api key>
```

```
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-example-com-ca
  namespace: your-ingress-namespace
spec:
  commonName: test.example.com
  dnsNames:
  - test.example.com
  issuerRef:
    group: cert-manager.io
    kind: ClusterIssuer
    name: letsencrypt-dns
  secretName: test-example-com-ca
```

Придется подождать пока dns запись раскатится по dnsам.
