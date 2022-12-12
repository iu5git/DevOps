# Лабораторная работа 8 (Итоговый проект)

## Подготовка
Для выполнения лабораторной работы вам понадобятся:
- какой-нибудь ваш проект (например, курсовая по сетям, заготовки диплома или что-нибудь еще)
- Виртуальная машина с kubernetes (результат прошлых лабораторных работ, kubernetes тоже оттуда)

## Задание лабораторной работы
1. Запушить ваш проект в собственный репозиторий на https://bmstu.codes/
2. В настройках проекта Settings -> General -> Visibility, project features, permissions включить **Pipelines**. Не забыть сохранить. Если все ок, то в настройках появится раздел Settings -> CI/CD
3. Подлключаем раннер по инструкции в Gitlab 
```sh
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permissions to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab CI user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```

Добавим юзера gitlab-runner в группу docker
```sh
usermod -aG docker gitlab-runner
```

Создаем раннер на сервере командой
```sh
gitlab-runner register --url https://bmstu.codes/
```
! Важно, проверьте, что хост гитлаба с https. Вставляем registration token, в списке тегов укажите что угодно, например, localhost.
Тип раннера **shell**


Немного магии
```sh
rm -rf /home/gitlab-runner/.bash_logout 
```
p.s. если у вас падает пайплайн с ошибкой 
> ERROR: Job failed: prepare environment: exit status 1. Check https://docs.gitlab.com/runner/shells/index.html#shell-profile-loading for more information

то вы забыли удалить .bash_logout


4. Создаем в корне проекта .gitlab-ci.yml вставляем в него тестовую джобу
```sh
job:
  tags:
    - localhost
  script:
    - echo test
```
Коммитим, пушим, проверяем, что CI отработал.

5. Создаем в репозитории Dockerfile и собираем образ из нашего проекта.
```sh
docker build -t myimage_name:mytag ...
```

6. В .gitlab-ci.yml создаем 3 стейджа: build, upload, deploy
7. В build stage создаем джобу build в которой собираем наш образ и тегируем его по хешу коммита
docker build -t myimage_name:$CI_COMMIT_SHORT_SHA ...

```yml
script:
  - docker build -t myimage_name:$CI_COMMIT_SHORT_SHA ...
```

8. В upload stage создаем джобу upload в которой загружаем наш образ в kind
```yml
script:
  - kind load docker-image myapp:${CI_COMMIT_SHORT_SHA}
```

1. В deploy stage создаем джобу deploy. 
```yml
  environment:
    name: production
  script:
    - kubectl get pods
```
Деплой должен будет упасть, потому что мы не сообщили параметры подключения к кластеру. Откроем настройки проекта Settigns -> CI/CD -> Variables и создадим переменную с именем KUBECONFIG типа File, в environment scope должен был появиться наш production, и включить protected variable. Скопируем значение нашего конфига из /root/.kube/config и вставим его

Перезапускаем пайплайн, CI должен пройти и в логах увидим список подов.

10. Создаем папку manifests, в ней либо один manifest.yml, либо несколько service.yml, deployment.yml, ingress.yml. Описываем манифесты для service, deployment и ingress. Также в корне проекта создайте папку etc или configs и скопируйте туда все конфиги приложения. 
11. Создаем конгфигмап
```sh
kubectl create configmap myapp-conf --from-file=< etc или config>/ --namespace=default -o yaml --dry-run=client | kubectl apply -f -
```
12. Деплоим руками первоначальные манифесты
```sh
kubectl apply -f manifests/
```
13. Обновляем джобу deploy, чтобы обновлять конфиги и образ автоматически
```yml
  script:
    - kubectl create configmap myapp-conf --from-file=< etc или config>/ --namespace=default -o yaml --dry-run=client | kubectl apply -f -
    - kubectl set image deployment/my-deployment mycontainer=myapp:${CI_COMMIT_SHORT_SHA}
```
14. Настройте CI, чтобы джобы build, upload, deploy запускались только по мастеру
❗ Этих пунктов хватит для сдачи ЛР.
15. Доп задание. Настройте запуск тестов в по открытому МРу
16. При желании и свободном времени, можно познакомится с пакетным менеджером helm и заменить джобу deploy на helm update.

## Подводим итоги
В результате лабораторной работы необходимо было сделать:
1. Запушить код в гитлаб
2. Настроить CI
3. Написать Dockerfile и собрать образ
4. Создать configmap, service, deployment и ingress в кубере
5. Настроить CI/CD для автоматического обновления