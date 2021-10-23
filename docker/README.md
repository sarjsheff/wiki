# Docker

Запускаем nginx:
```
docker run -it --rm -p 801:80 nginx
docker run -it --rm -p 801:80 nginx /bin/bash
```

Запускаем nginx фоновым процессом:
```
docker run --name nginx -d -p 801:80 nginx
```

Проверяем работоспособность:
```
curl -v http://localhost:801/
```

Список контейнеров:
```
docker ps
docker ps -a
docker ps --no-trunc --format='{{json .}}'
docker ps --no-trunc --format "{{.ID}} {{.Names}} {{.Command}}"
```

Остановка, удаление контейнера:
```
docker stop nginx
docker rm -f nginx
```

Запуск команды в работающем контейнере:
```
docker exec -ti nginx sh -c "ls /"
docker exec -ti nginx sh
docker attach nginx
```

Просмотр журнала:
```
docker logs -n 10 nginx
docker logs -f nginx
docker logs --since 10m nginx
```

Проброс файлов:
```
docker run -it --rm -p 801:80 -v $(pwd)/:/usr/share/nginx/html nginx
```

Удаляем все контейнеры:

```
docker rm -f $(docker ps -a -q)
```

Сохраняем изменения в имадж:

```
docker commit nginx my/nginximage
```

Сохраняем имадж в файл:
```
docker save -o myimage.tar my/nginximage
tar -tvf myimage.tar
```

Загружаем имадж из файла:
```
docker load --input fedora.tar
```

Виртуальная сеть:
```
docker network create test
docker run --name test --network test -d nginx
docker run --name test1 --network test -it --rm alpine ping test
```

```
docker build -t test/test . 
docker run -it --rm test/test
```
