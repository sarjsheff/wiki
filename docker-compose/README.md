# docker compose

## verify config

```
docker-compose config
```

## variable in config

По умолчанию переменные берутся из .env и окружения (окружение главнее).

```
TEST=444 docker-compose config
```

Читать переменные из фала:

```
docker-compose --env-file <file>
```

```
${VARIABLE:-default} # default если переменная пустая или не установлена
${VARIABLE-default} # default если переменная не установлена
${VARIABLE:?err} # завершится с ошибкой err если переменная пустая или не установлена
${VARIABLE?err} # завершится с ошибкой err если переменная не установлена
$$ # escape для $
```

## profile

Позволяют разделять конфигурационный файл на секции для гибкого запуска.

```
docker-compose --profile test config
```

## Наследование

Конфиг в файле docker-compose.override.yaml всегда применяется.

Слияние двух конфигов:
```
docker-compose -f docker-compose.yaml -f docker-compose.prod.yaml config
```

Наследование определенного сервиса из файла:
```
    extends:
      file: common.yaml
      service: temp
```

## Network

По умолчанию все контейнеры из одного compose файла доступны по имени и находятся в одной виртуальной сети.

Дополнительные алиасы для контейнеров:

```
    links:
      - "web:webhost" # контейнер web будет доступен по имени webhost
```

## Обновление без пересоздания зависимых контейнеров

```
docker-compose up --no-deps
```

## depends_on

Позволяет настроить очередность запуска контейнеров.
