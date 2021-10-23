## nginx ingress

### Установка

Установка NodePort:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.4/deploy/static/provider/baremetal/deploy.yaml
```

Проброс через lb:

```
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx-controller-loadbalancer
  namespace: ingress-nginx
spec:
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
    - name: https
      port: 443
      protocol: TCP
      targetPort: 443
  type: LoadBalancer
```

Пример установки:

```
#!/bin/sh
k3d cluster delete test
k3d cluster create test --agents 1 -p "880:80@loadbalancer" -p "8443:443@loadbalancer" --k3s-server-arg '--no-deploy=traefik'
sleep 10
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.4/deploy/static/provider/baremetal/deploy.yaml
kubectl apply -f nginx-ingress-lb.yaml
```

### Использование

При использовании в ingress нужно указать ingressclass через аннотацию:

```
  annotations:
    kubernetes.io/ingress.class: "nginx"
```

### Настройки

Пример настроек для nginx ingress (применяются автоматически после создания/изменения):

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
data:
  proxy-connect-timeout: "11"
  proxy-read-timeout: "120"
  proxy-send-timeout: "120"
```

Список всех параметров (https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/).

Можно посмотреть (и проверить выставленные параметры) конфиг nginx для ingress: ```kubectl exec daemonset.apps/ingress-nginx-controller -it -n ingress-nginx -- cat nginx.conf```

Например: ```kubectl exec daemonset.apps/ingress-nginx-controller -it -n ingress-nginx -- cat nginx.conf | grep 'proxy_connect_timeout'```