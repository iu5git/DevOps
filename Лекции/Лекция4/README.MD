# Docker network

## Установка docker-compose
[https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)

## Примеры docker-compose
* Создание сети

      docker network create --driver=bridge test-bridge
      docker run -it -d --name A1 --network test-bridge alpine ash
      docker run -it -d --name A2 --network test-bridge alpine ash
      docker container attach A1
        ping -c 2 A2
* [Пример запуска](../../Лабы/Лаб3/test-compose/docker-compose.yml)
* [Конфигурирование среды](../../Лабы/Лаб3/python-ui-database/docker-compose.yml)
* [Базовый пример nginx](docker-compose.yml)
* [Балансировка нагрузки nginx](../../Лабы/Лаб3/nginx-static-balancer/docker-compose.yml)
* [Балансировка нагрузки haproxy](../../Лабы/Лаб3/haproxy-static-balancer/docker-compose.yml)