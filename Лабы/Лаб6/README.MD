# Ansible, Playbook

## Подготовка к работе

- Работа в операционной системе семейства Linux
- Устанвленные Docker,Docker-compose
- Установленный пакет Python3

### Дополнительные материалы
Для выполнения лабораторной работы необходимы будут материалы лекций:
- [Docker](https://www.youtube.com/watch?v=WjRye2bByEw&list=PLLELLTvDgUQ-iwnE9coLhb-ynyZUGzW6q&index=2)
- [Docker-compose](https://www.youtube.com/watch?v=-bbxABMdHig&list=PLLELLTvDgUQ-iwnE9coLhb-ynyZUGzW6q&index=5)
- [Ansible](https://www.youtube.com/watch?v=59HZ6R6nYQ4&list=PLLELLTvDgUQ-iwnE9coLhb-ynyZUGzW6q&index=6)

### Подготовка проекта
  - скачать проект [DevOps](https://github.com/iu5git/DevOps) на локальную машину: Code ->Download Zip
  ![download.png](download.png)
  - Разархивировать проект и зайти в папку с проектом:
```
cd DevOps-master/Лабы/Лаб6

Структура директории

```

### Установка lab6-agent и проверка тестрового стенда
```
cd  ssh-agent
# собираем образ базового контейнера для лабы
./build.sh

# поднимаем тестовый стенд
docker-compose up -d --scale app=3

# заходим в контейнер с ansible
docker exec -it `docker ps -aqf "name=6-ansible-1"` bash 
```


## Задачи лабораторной работы
### Задание 1: Изучить работу ansible на примере adhoc команд

Пример вывода, попробуем вывод
```
root@8eb61b55174f:/# ansible all -m ping
6-app-2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
6-app-3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
6-app-1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
root@8eb61b55174f:/# ansible application -m ping
6-app-1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
6-app-2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
root@8eb61b55174f:/# ansible database -m ping
6-app-3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
root@8eb61b55174f:/# 

```


### Задание 2: Изучить работу ansible inventory

### Задание 3: Изучить работу групп хостов
https://karthi-net.medium.com/how-to-scale-services-using-docker-compose-31d7b83a6648

## Формат отчета
- Doc-документ
- Скриншоты результатов заданий и ответы на вопросы задания
- Отчеты присылать на [Яндекс-форму](https://forms.yandex.ru/u/63428b48921ce71d986818ef/)

## Контрольные вопросы
