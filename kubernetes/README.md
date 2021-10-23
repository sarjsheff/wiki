Kubernates (k8s) это система для управления контейнеризоваными приложениями в кластерном окружении. k3s полностью совместимый (прошел все тесты) дистрибутив kubernates с минимальным потреблением ресурсов.

k3s:

 - Containerd & runc - Container runtime низкий уровень управления контейнерами.
 - flannel - сетевой уровень управление адресами
 - coredns - внутренний DNS сервер
 - metrics-server - сервис для сбора и распростронения информации о вычеслительных ресурсах для реализации механизма автоматического маштабирования
 - traefik - ingress http и https proxy 
 - Klipper-lb - балансировщик трафика
 - Kube-router - сетевой стек

# k3d создаем тестовый кластер

Устанавливаем k3d https://k3d.io/

Создаем тестовый кластер:
```
k3d cluster create testcl -p "8081:80@loadbalancer" -p "3000:3000@loadbalancer" --agents 2
```

```--agents 2``` количество узлов кластера
```-p "8081:80@loadbalancer"``` пробрасываем порт 80 (k3d-proxy) на внешний порт 8081

После создания кластера обновляется конфиг утилиты управления kubectl ```~/.kube/config```. Кластер можно удалить, остановить и запустить ```k3d cluster -h```. Под докер будет запущенно два контейнера:

 - Входной прокси сервер на базе nginx (образ контейнера rancher/k3d-proxy)
 - Три узла: один мастер и два нода (образ контейнера rancher/k3s)

# kubectl

Список namespaceов:

```
kubectl get namespaces
```

Список узлов кластера:

```
kubectl get nodes
```

Описание (документация) по разным типам ресурсов:

```
kubectl explain nodes
```

Подробная информация по ресурсу (в примере по ноду):

```
kubectl describe nodes/k3d-testcl-server-0
```

Посмотреть все ресурсы во всех namesapcах:

```
kubectl get all -A
```

Посмотреть все ресурсы в определенном namespacе:

```
kubectl get all -n kube-system
```

Информация об утилизации вычислительных ресурсов:

```
kubectl top node
```

Создание тестового namespace:

```
kubectl create namespace test
```

# Pods

Запуск контейнера:

```
kubectl run my-nginx --image=nginx -n test
```

Run запустит контейнер и создаст ресурс в кластере типа pod.

Посмотреть все запущенные контейнеры (podы) в namespace с именем test:

```
kubectl get pods -n test
kubectl get pods -n test -o wide
```

Детальная информация по контейнеру (podу):

```
kubectl describe pods/my-nginx -n test
```

Журнал контейнера:

```
kubectl logs pods/my-nginx -n test
```

Временный (пока запущена команда) проброс порта 80 на 8118:

```
kubectl port-forward -n test pods/my-nginx 8118:80
```

Проверяем ```curl http://localhost:8118/```.

Получить описание podа в yamlе:

```
kubectl get pods/my-nginx -n test -o yaml
```

Удаляем pod (контейнер):

```
kubectl delete pods/my-nginx -n test
```

Создаем файл описания ресурса типа pod ```my-nginx.yaml```:

```
kind: Pod
apiVersion: v1
metadata:
  namespace: test
  name: my-nginx
spec:
  containers:
  - image: nginx
    name: my-nginx
```

Применяем (создаем) ресурс (pod) из файла ```my-nginx.yaml```:

```
kubectl apply -f my-nginx.yaml
```

Удаление созданного ресурса:

```
kubectl delete -f my-nginx.yaml
```

# ConfigMap

ConfigMap предназначен для хранения не секретных данных в виде ключ-значение. ConfigMap можно подключать к подам виде переменных окружения, аргументов командной строки или файлов.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
  namespace: test
data:
  index.html: |
    <html><body>my-config</body></html>
  index1.html: |
    <html><body>my-config1</body></html>
```

Посмотреть:

```
kubectl describe configmap my-config -n test 
```

Получить содержимое по ключу/имени файла:

```
kubectl get configmap my-config -n test -o jsonpath='{.data.index\.html}' 
```

Создать configmap из директории:

```
kubectl create configmap my-config1 -n test --from-file=configmap-data/
```

Удалить configmap:

```
kubectl delete configmap my-config -n test
```

Монтируем файл index1.html из configmap my-config в поде по пути /usr/share/nginx/html/index.html:

```
kind: Pod
apiVersion: v1
metadata:
  namespace: test
  name: my-nginx
spec:
  containers:
  - image: nginx
    name: my-nginx
    volumeMounts:
    - name: config-volume
      mountPath: /usr/share/nginx/html/index.html
      subPath: index1.html
  volumes:
    - name: config-volume
      configMap:
        name: my-config
```

# Service

Сервис в Kubernetes — это абстрактный объект, который определяет логический набор подов и политику доступа к ним. Сервисы создают слабую связь между подами, которые от них зависят. У каждого пода есть уникальный IP-адрес, эти IP-адреса не доступны за пределами кластера без использования сервиса.

Предоставляем доступ до nginx через внешний порт 3000:

```
---
apiVersion: v1
kind: Service
metadata:
  name: my-nginx-svc
  namespace: test
spec:
  ports:
    - port: 3000
      protocol: TCP
      targetPort: 80
  selector:
    app: my-nginx
  sessionAffinity: None
  type: LoadBalancer
```

или

```
kubectl expose pod my-nginx -n test --port=3000 --target-port=80 --type=LoadBalancer
```

Типы сервисов:

ClusterIP

Тип по умолчанию. Разворачивает сервис на внутреннем ip без использования externalIps доступен только из внутренней сети.

NodePort

Проброс портов в ограниченном диапазоне (30000-32767) на внешний адрес. Можно сконфигурировать внешний ip (в том числе и задать loopback) и диапазон портов. Для k3s ```--kube-proxy-arg='nodeport-addresses=127.0.0.0/8' --service-node-port-range=8000-50000```.

```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: MyApp
  ports:
    - port: 80 # такой же как и targetPort
      targetPort: 80 # порт на podе
      nodePort: 30007 # внешний порт из диапазона (30000-32767)
```

LoadBalancer

Пробрасывает внутренний сервис (со всех узлов) через один программный прокси балансировщик. 

ExternalName

Предназначен для прокисрования на внешний ресурс.

### externalIPs

Для сервисов с любым типом можно указать внешний ip адрес на котором будет доступен данный сервис (кроме k3d). 

```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - port: 80 # внешний порт
      targetPort: 80 # порт на podе
  type: ClusterIP
  externalIPs:
  - 192.168.4.3 # внешний ip адрес
```

# Volume

# Deployment

**Требует проверки**

Обертка над Pod для гибкого управления развертыванием и обновлением. Появляются возможности по перезапуску, остановке, откату и маштабированию.

  replicas - Количество разворачиваемых подов. 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
  namespace: test
spec:
  replicas: 2 # Количество разворачиваемых podов
  selector:
    matchLabels:
      apptype: my-nginx
  template: # Шаблон podа
    metadata:
      namespace: test
      name: my-nginx
      labels:
        apptype: my-nginx
    spec:
      containers:
      - image: nginx
        name: my-nginx
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/nginx/html/index.html
          subPath: index1.html
      volumes:
        - name: config-volume
          configMap:
            name: my-config
```

Обновление до версии:

```
kubectl -n test set image deployments/my-nginx my-nginx=nginx:1.20.1
```

Перезапуск:

```
kubectl -n test rollout restart deployments/my-nginx
```

Откат:

```
kubectl -n test rollout undo deployments/my-nginx
```

История:

```
kubectl -n test rollout history deployments/my-nginx
```

Маштабирование:

```
kubectl -n test scale deployments/my-nginx --replicas=10
kubectl -n test autoscale deployments/my-nginx --min=10 --max=15 --cpu-percent=80
```

### Compose docker-compose в kuber

### kustomize

### helm

## [Ingress](ingress/)

## [cert-manager TLS выпуск сертификатов](cert-manager/)


