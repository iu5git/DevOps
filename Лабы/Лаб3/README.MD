 Масштабируемость и отказоустойчивость + docker compose


## Подготовка к работе
  - скачать проект [DevOps](https://github.com/iu5git/DevOps) на локальную машину: Code ->Download Zip
  ![download.png](download.png)
  - Разархивировать проект и зайти в папку с проектом:
    cd DevOps-master/Лабы/Лаб3
  - Для выполнения лабораторной работы необходимы будут материалы лекций:
    - [Docker](https://www.youtube.com/watch?v=WjRye2bByEw&list=PLLELLTvDgUQ-iwnE9coLhb-ynyZUGzW6q&index=2)
    - [Docker-compose](https://www.youtube.com/watch?v=-bbxABMdHig&list=PLLELLTvDgUQ-iwnE9coLhb-ynyZUGzW6q&index=5)
## Задачи лабораторной работы
### Задание 1: Изучить работу docker-compose на примере проекта [test-compose](https://github.com/iu5git/DevOps/tree/main/Лабы/Лаб3/test-compose)
    cd test-compose
    docker compose up
   **Задача**: Заменить надпись на свое имя, запустить контейнер, продемонстрирать результат 
### Задание 2: Изучить методы балансировки нагрузки между узлами кластера. 
   - Изучить структуру проектов: [Ha proxy balancer](https://github.com/iu5git/DevOps/tree/main/Лабы/Лаб3/haproxy-static-balancer), [nginx-balancer](https://github.com/iu5git/DevOps/tree/main/Лабы/Лаб3/nginx-static-balancer)
   - Собрать статистику на 10 запросах для методов балансировки и объяснить результаты: 
   1. RoundRobin
   2. RoundRobin с добавлением веса
   3. LeastConnection 
   4. LeastConnection с добавлением веса
   5. (Дополнительно) Написать скрипт сбора статистики на 1000 запросах для получения блее четких данных распределения
### Задание 3: Многокомпонентый проект docker-compose 
   1. Изучить структуру проекта [сервис-база данных приложения развернутого в кластере из двух контейнеров](https://github.com/iu5git/DevOps/tree/main/Лабы/Лаб3/python-ui-database)
   2. Добавить запись в базу используя встроенный контейнер phpmyadmin
   3. (Дополнительно) Добавить запись в базу используя внешний клиент, например [Datagrip](https://www.jetbrains.com/datagrip/).
   4. Добавить в проект еще один сервис app (по аналогии с заданием 2), добавить балансировщик нагрузки для сервисов app, испльзуя либо контейнер nginx либо haproxy

*Формат отчета:*
- Doc-документ
- Скриншоты результатов заданий и ответ на вопрос задания
- Отчеты присылать на [Яндекс-форму](https://forms.yandex.ru/u/63428b48921ce71d986818ef/)

*Контрольные вопросы:*
- Какие способы организации работы с сетью есть в Docker?
- Как определяются списки в стандарте YAML?
- При "пробросе" портов контейнера docker-compose что стоит на первом месте- порт хоста или порт контейнера?
- Какой метод балансировки нагрузки в каком случае используется?
