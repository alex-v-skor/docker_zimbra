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
│   ├── install.sh
│   └── zimbra-install
│       └── zimbra_install_keystrokes
├── README.md
├── entrypoint.sh
└── zimbra.repo
```

## Подготовка
Сначала создайте пользовательскую сеть docker для zimbra. Это позволит нам определить `IP-адрес` контейнера.
Создаем сеть с именем zimbra_bridge в адресном пространстве 192.168.2.0/24, используя следующую команду:

```
    docker network create -d bridge --subnet 192.168.2.0/24 zimbra_bridge
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

1. Клонируем репозиторий:
```
    git clone https://github.com/alex-v-skor/docker_zimbra
```
2. Переходим в директорию docker_zimbra
```
    cd docker_zimbra
```
3. Отредактируйте Makefile, если вы хотите изменить имя базового образа для следующей сборки. Имя по умолчанию - zimbra-centos-base

    sed -i 's/^IMAGE=.*/IMAGE=new-image-name/g' Makefile

4. Создайте zimbra base docker image, он будет основой для нового контейнера.

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
Создайте базовый образ командой  make или командой: 
```
    make build
```
5. После успешной сборки  запустите контейнер с новым базовым образом: 
```
    zimbra make run
```
Эта команда запустит контейнер под названием "zimbra" в detached mode, потому что по умолчанию выполняется команда /usr/sbin/init вы не можете подключить терминал tty.

6. Для начала установки zimbra присоедините к контейнерному терминалу zimbra и выполните

```
     make exec
```

7. Полчив доступ к shell в контейнере, запустите скрипт установки Zimbra:

```
    cd /opt
    sh ./install.sh
```

После завершения работы скрипта вы можете попасть в консоль администрирования Zimbra: https://YOUR_HOST_IP:7071
                                                      или пользовательский интерфейс: https://YOUR_HOST_IP

Вместо YOUR_HOST_IP можно писать ip адрес или имя своего домена.
