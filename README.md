## Zimbra on CentOS Docker image

Репозиторий для запуска Zimbra сервера в Docker.



Древовидная структура каталогов репозитория:

```bash
.
├── Dockerfile
├── etc
│   └── named
│       ├── db.domain
│       └── named.conf
├── Makefile
├── opt
│   ├── start.sh
│   └── zimbra-install
│       ├── zcs-rhel7.tgz
│       └── zimbra_install_keystrokes
├── README.md
├── run.sh
├── setup.sh
├── shell.sh
└── zimbra.repo
```

## Подготовка
Сначала создайте пользовательскую сеть docker для zimbra. Это позволит нам определить `IP-адрес` контейнера.
Создаем сеть с именем zimbra_bridge в адресном пространстве 192.168.2.0/24, используя следующую команду:

```
    docker network create -d bridge --subnet 192.168.2.0/24 zibra_bridge
```
Проверяем по завершении команды:
```
    # docker network ls

    NETWORK ID          NAME                DRIVER
    f16cc34759a8        none                null
    cd4f9b056c74        host                host
    6fdeb55834bf        bridge              bridge
    8c67bf16fc36        zimbra_bridge       bridge
```
## Пример использования:

`1.` Клонируем репозиторий:

    git clone https://github.com/alex-v-skor/docker_zimbra

`2.` Переходим в директорию docker_zimbra

    cd docker_zimbra

`3.` Загружаем последнюю версию  Zimbra Collaboration Server. Например, для загрузки Open Source edition:

    wget -O opt/zimbra-install/zcs-rhel7.tgz  https://files.zimbra.com/downloads/8.7.1_GA/zcs-8.7.1_GA_1670.RHEL7_64.20161025045328.tgz

`4.` Отредактируйте Makefile, если вы хотите изменить имя базового образа для следующей сборки. Имя по умолчанию - zimbra-centos-base

    sed -i 's/^IMAGE=.*/IMAGE=new-image-name/g' Makefile

`5.` Создайте zimbra base docker image, он будет основой для нового контейнера.

Перед запуском make изменените имя хоста, переменная HOSTNAME в файл setup.sh. Она участвует в создании пути к папке,
которая будет использована для подключения /opt/zimbra из контейнера на ност докер сервера. Так же в этом файле можно добавить пакеты, которые будут установлены 
в базовый образ CentOS. Если вы планируете использовать образ docker image отличный от CentOS 7, измените директиву FROM в Dockerfile.

```
sed -i 's/^FROM .*$/FROM centos:latest/' Dockerfile

```

В файле opt/zimbra-install/zimbra_install_keystrokes, измените "y" на "n" в зависимости от устанавливаемых ролей Zimbra server:

```
$ cat opt/zimbra-install/zimbra_install_keystrokes
y
y
y
y
y
n
y
y
y
y
y
y
y

```
Создайте базовый образ командой  make или командой docker build --rm -t Имя_образа

6. После успешной сборки  запустите контейнер с новым базовым образом zimbra. Используйте для этого скрипт run.sh. Предварительно измените переменные:

```
$ cat run.sh

#!/bin/bash
CONT_NAME="zimbra"
CONT_DOMAIN="example.com"
CONT_S_HOSTNAME="mail"
CONT_L_HOSTNAME="mail.example.com"
CONT_BRIDGE="zimbra_bridge"
CONT_IP="192.168.2.2"
ZIMBRA_PASS="Password321"
docker run -d --privileged \
    --name "${CONT_NAME}" \
    --hostname zimbra.example.com \
    --net "${CONT_BRIDGE}" \
    --ip "${CONT_IP}" \
    -e TERM="xterm" \
    -e "container=docker" \
    -e PASSWORD="${ZIMBRA_PASS}" \
    -e HOSTNAME="${CONT_S_HOSTNAME}" \
    -e DOMAIN="${CONT_DOMAIN}" \
    -e CONTAINERIP="${CONT_IP}" \
    -e NAME="${CONT_NAME}" \
    -v /var/"${CONT_L_HOSTNAME}"/opt:/opt/zimbra  \
    -v /etc/localtime:/etc/localtime:ro \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v $(pwd)/zimbra.repo:/etc/yum.repos.d/zimbra.repo \
    -p 25:25 -p 80:80 -p 465:465 -p 587:587 \
    -p 110:110 -p 143:143 -p 993:993 -p 995:995 \
    -p 443:443 -p 8080:8080 -p 8443:8443 \
    -p 7071:7071 -p 9071:9071 \
    zimbra-centos-base \
    /usr/sbin/init
```

Если Вы не используете локальный репозиторий zimbra, удалите строку -v ./zimbra.repo:/etc/yum.repos.d/zimbra.repo.
Ссылка на мануал, как создать репозиторий Zimbra: https://wiki.zimbra.com/wiki/Zimbra_Collaboration_repository

Запустите новый zimbra контейнер:

```
    sh ./run.sh
```

Эта команда запустит контейнер под названием "zimbra" в detached mode, потому что по умолчанию выполняется команда /usr/sbin/init вы не можете подключить терминал tty.

7. Для начала установки zimbra присоедините к контейнерному терминалу zimbra и выполните /bin/bash

```
    docker exec -it zimbra /bin/bash
```

или просто запустите скрипт:

```
    sh ./shell.sh
```

Полцчив доступ к shell в контейнере, запустите скрипт установки Zimbra:

```
    cd /opt
    sh ./start.sh
```

После завершения работы скрипта вы можете попасть в консоль администрирования Zimbra: https://YOUR_HOST_IP:7071
                                                      или пользовательский интерфейс: https://YOUR_HOST_IP

Вместо YOUR_HOST_IP можно писать ip адрес или имя своего домена.
