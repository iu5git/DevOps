# Лабораторная работа 7

> ❗ **Задание**
> В лабораторной будут встречаться такие блоки, их необходимо проработать и указать результат в отчете. По ним могут быть вопросы на защите.

## Подготовка рабочего окружения

Для работы нам понадобятся утилита kubect и локальный кластер kubernetes. Мы рассматриваем установку кластера в ваших виртуалках6 поэтому используем утилиту kind. Если есть желание, можно использовать и отдельный minikube.
p.s. Утилита kind требует наличие докера в системе

1. Установка kubectl
Ставим утилиту по инструкции для linux внутри виртуальной машины, если у вас другой вариант установки, то смотрите альтернативные методы https://kubernetes.io/docs/tasks/tools/

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version
```
2. Установка Kind
Аналогично устанавливаем Kind https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
```

3. Создаем кластер
```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```
Если команда отработает успешно, то получим работающий кластер. проверим что все ок, командой 
```bash
kubectl get ns
```

Если получаем список namespace, то кластер создался, ставим ingress (что и зачем будет позднее)

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```


## Знакомство с kubernetes
Все объекты в kubernetes - это ресурсы. Чтобы получить список ресурсов используется команда **kubectl get**

Чтобы посмотреть список всех возможных ресурсов в кластере с их алиасами используется команда **kubectl api-resources**

Так команда **kubectl get namespaces** или **kubectl get ns** выведет список неймспейсов по которым сгруппированы остальные ресурсы.

Следующий важный ресурс в kubernetes - **POD**. Pod - единица работы в kubernetes, pod создается, запускается на подходящей ноде, работает и завершается. Pod может состоять из нескольких контейнеров (хотя чаще все же из одного), которые гарантировано запускаются вместе на одной ноде.

Посмотрим список подов в kube-system
```bash
kubectl get pods -n kube-system
```

> ❗ **Задание**
> Изучите список подов в kube-system, объясните зачем нужны эти компоненты, укажите это в отчете.

Для просмотра логов нужно воспользоваться командой 
```bash
kubectl -n kube-system logs <имя пода>
```

## Работа с kubernetes

Создадим под c простым nginx, для этого выполним команды

```bash
cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
EOF
```
p.s. Стоит отметить, что данный синтаксис команды просто позволяет передать параметры в команду из стандратного потока ввода. Аналогичного результата можно достичь через сознание файла. Например:

```bash
cat <<EOF > nginx_pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
EOF
kubectl apply -f nginx_pod.yml
```
Kubectl преобразует yaml структуру в запрос к api серверу kubernetes. Отсюда для создания ресурса необходимо указать достаточную информацию о создаваемом ресурсе:
apiVersion - версия апи
kind - тип ресурса
metadata.name - имя ресурса
spec - уже спецификация конкретного ресурса
Подробнее про спецификацию можно почитать тут https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#pod-v1-core


Проверим, что наш под создался. 
```bash
kubectl get pods
# nginx      1/1     Running   0          11m
```
Должны увидеть наш под nginx, в статусе Running, и 1/1 (те все контейнеры у нас запустились). Если указать параметр -o wide можно увидеть доп информацию

```bash
kubectl get pods -o wide
# nginx      1/1     Running   0          13m   10.244.0.6   kind-control-plane
```
К содержимому добавились ip пода и нода, на которой под запустился.

Создадим еще 1 под и подключимся к нему в интерактивном режиме
```bash
cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ["sleep", "infinity"]
EOF

kubectl exec -it netshoot -- bash
```
Дернем из этого пода созданный ранее nginx (ip будет у каждого свой!)
```bash
curl -v 10.244.0.6:80
```

Выйдем из под или откроем второе окно терминала.

Стоит помнить, что pod - это почти неизменяемая сущность. Если под создан, то  в нем нельзя менять параметры влияющие на работу, за исключение образа. Например попробуем поменять команду запуска. Для этого воспользуемся командой:
```bash
kubectl edit pod nginx
```
и допишем в контейнер nginx строчку command: ["sleep", "infinity"]. Получим следующую ошибку:

 > spec: Forbidden: pod updates may not change fields other than spec.containers[*].image, spec.initContainers[*].image, spec.activeDeadlineSeconds or spec.tolerations (only additions to existing tolerations)

 Таким образом, чтобы что-то поменять в спеке пода, необходимо пересоздать его. Удалим под nginx и пересоздадим его буквально той же самой командой

```bash
kubect delete pod nginx
cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
EOF
kubectl get pods -o wide
```
> ❗ **Задание**
> Сравните старый и новый ip у подов nginx. Сделайте вывод.
> Представьте, что есть еще 1 сервис, который ходит по ip в наш nginx, что с ним будет?

Получается на голый ip пода полагаться нельзя, поэтому вводят сетевые абстракции - сервисы. Service - это абстракция, которая позволяет получать доступ к поду в независимости от их числа и ip адресов самих подов. Сервис выбирает все поды подходящие условиям и распределяет трафик на них.

> ❗ **Задание**
> Пересоздайте, обновите или добавьте лейбл к поду nginx с помощью kubectl edit, kubectl label или kubectl apply лейбл **app=nginx**

Создадим сразу два типа сервисов CluesterIp и Headless
```bash
cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
EOF

cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-headless
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
EOF
```

Проверяем, что наши сервсисы создались
```bash
kubectl get svc
```

Вернемся в под netshoot и проверим работоспособность нашего серсива
```bash
curl 10.96.99.34
curl nginx-service
curl nginx-service.default
curl nginx-service.default.svc
curl nginx-service.default.svc.cluster.local
curl nginx-service-headless
```
> ❗ **Задание**
> Сравните запрос к nginx-service и nginx-service.default.svc.cluster.local В чем разница? В каких случаях они работают?
> Сравните ip у днс записей nginx-service и nginx-service-headless (например командой host) В чем их различие?

Однако clusterIp и headless сервисы работаю только внутри самого кластера, для того, чтобы получить доступ к приложению снаружи используются другие типы сервисов:
**NodePort** - создает связь между портом на ноде и подом (аналог опции -p у докера)
**LoadBalancer** - работает при наличии балансировщика, чаще всего в облаках. Берет выделенный ip и связывает его с ip подов.

> ❗ **Задание**
> В кластере уже существует один сервис NodePort, найдите его (мб понадобился почитать kubect get --help)


NodePort создавать довольно хлопотно, потому что порты не должны пересекаться, а для доступа все ноды должны быть доступны клиентам, что не всегда безопасно. Поэтому есть гибридное решение - Ingress. Ingress - это прокси сервер, который доступен клиентам, а дальше он маршрутизирует запросы по внутренним сервисам.

Создадим Ingress для нашего сервиса nginx-service
```bash
cat <<EOF | kubectl apply -f-
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
EOF
```

Выполним curl localhost:80 напрямую с виртуальной машины, если все выполнено верно, то на этом этапе вы увидите приветственную стрницу nginx. Если вы пробросите порты 80,433 из виртуалки, то и в браузере должны увидеть результат.

Таким образом мы настроили всю цепочку трафика к нашему приложению: Ingress -> service(ClusterIP) -> Pod

До этого момента мы в основном рассматривал сетевую составляющую kubernetes кластера, теперь поговорим об управлении подами. Как мы уже поняли, под можно создать, удалить, а когда он заканчивает работать, то завершается. При этом под почти неизменяемая сущность, а значит нам не получится поменять команду запуска или переменные окружения без пересоздания. К счастью, есть абстракции более высокого уровня, которые сами создают поды и управляют и жизненным циклом. 

Основные абстракции kubernetes:
**Deployment** - самый распространенный тип сущности в kubernetes, основная идея поднять группу подов, поддерживать их численность и предоставляет механизмы постепенного автоматического обновления.
**StatefulSet** - также как деплой реализует управление подами, но в отличие от деплоймента, который делает поды обезличенными, StatefulSet сохраняет четкую идентичность всех подов (у каждого свое имя, которое не меняется)
**DaemonSet** - Если Deployment и StatefulSet поддерживают заданное число реплик, то задача daemonSet запустить на каждой ноде один экземпляр приложения. В основном для каких-то служебных приложений.
**Job** - создает под для выполнения ограниченной во времени задачи, следит, чтобы задача завершилась успешно. 
**CronJob** - переодически создает Job, который уже создает под.

Подробнее про спецификацию Deployment можно тут https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#deployment-v1-apps


Итак, удалим наш старый под nginx и создадим deployment

```bash
cat <<EOF | kubectl apply -f-
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
EOF
```

Основыне особенности в спеке Deployment - это наличие поля replicas, которые указывают на число копий приложения. matchLabels - определяет идентификатор, по которому kubernetes понимает, что поды принадлежат данному deployment.

> ❗ **Задание**
> Мы удалили старый под, что будет если дернуть curl localhost:80 ? Почему?

> ❗ **Задание**
> Проверьте, какие ресурсы создались, пройдитесь по pod, replicaset и deploy


Проверим механизмы обновления deployment. Попытаемся обновить образ на несуществующий
```bash
kubectl set image deploy/nginx-deployment nginx=nginx:iam-not-exists
curl localhost:80
kubectl get pods
```
Более подробную информацию о ресурсе и его статусе можно с помощью команды **kubectl describe**
```bash
kubectl describe pod <который не может запуститься>
```

Откатимся на предыдущую версию
```bash
kubectl rollout undo deployment/nginx-deployment
```

Поды имеют мехнизмы жизнеобеспеченья, которые позволяют определять действительно ли приложение работает или нет, перед тем как запускать в него пользовательский трафик. Различают Liveness и Readiness (Подробнее тут https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

Liveness проба определяет работает ли приложение в целом, а Readiness - может ли в данный момент приложение принимать трафик. Упавшая Liveness приводит к перезапуску приложения, упавшая Readiness - удаляет под з трафика.

Пробы бывают нескольких типов:
httpGet - http запрос, успех = статус ответа 200-399
tcpSocket - установка tcp соединения. Установили или нет
exec - выполняем в контейнере команду, успех = код возврата 0

Применяем http пробу к нашему деплойменту

```bash
cat <<EOF | kubectl apply -f-
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 3
          periodSeconds: 3
EOF
```

И... спустя какое-то время у нас все поды сломаются и перейдут в статус CrashLoopBackOff, потому что мы ошиблись в запросе. 

> ❗ **Задание**
> Почините Liveness пробу


Поговорим про конфигурацию. В контейнере можно явно указывать переменные окружения, но более общим решением является использовать файлы конфигурации. Для этого в kubernetes существует специальный ресурс ConfigMap

```bash
cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configmap
data:
  student-server.conf: |
    server {
        listen         80 default_server;

        location / {
            return 200 'Hello <ЗАмени меня на что-то свое>';
        }
    }
EOF
```

И подклюаем конфиг к поду
```bash
cat <<EOF | kubectl apply -f-
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        livenessProbe:
            ...... Замени меня! .......
        volumeMounts:
         - name: nginx-cm
           mountPath: "/etc/nginx/conf.d"
           readOnly: true
      volumes:
      - name: nginx-cm
        configMap:
          name: nginx-configmap
EOF
```

Проверяем что все ок через curl localhost:80 и получаем наш ответ, который мы задали в конфиге.

> ❗ **Задание**
> Зайдите в любой под nginx и найдите наш конфиг


Существует аналогичная ConfigMap сущность под названием Secret. Работает она также как конфиг, только хранится в зашифрованном виде и монтируется через tmpfs.


Мы рассмотрели базовые моменты во время деплоя приложения в kubernetes кластер. Но это лишь верхушка айсберга и возможностей kubernetes. За рамками лабораторной осталась работа с дисками (Persistent Volume и PVC), требование и ограничение ресурсов (Requests и Limits), управление распределением подов по нодам (NodeSelector, Affinity and Anti-affinity, Taints and Tolerations)

## Контрольные вопросы
1. Что такое kuberneets и зачем он нужен?
2. Расскажите про основные компоненты kubernetes и покажите их в kube-systems
3. Расскажите про создание пода из yaml, основные поля.
4. Расскажите про сервисы ClusterIp и Headless
5. Расскажите про сервисы NodePort и LoadBalancer
6. Расскажите про Ingress
7. Расскажите про Deployment, StatefulSet и DaemonSet
8. Расскажите про Job и CronJob
9. Расскажите про ConfigMap и Secret
10. Перечислите основные команды kubectl, рассмотренные в лабе