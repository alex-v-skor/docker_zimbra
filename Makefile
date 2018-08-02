HOSTNAME=mail.concord-consulting.pro
IMAGE_NAME=zimbra-centos
CONT_NAME=zimbra
CONT_DOMAIN=concord-consulting.pro
CONT_S_HOSTNAME=mail
CONT_L_HOSTNAME=mail.concord-consulting.pro
CONT_BRIDGE=zimbra_bridge
CONT_IP=192.168.2.2
ZIMBRA_PASS=P@ssw0rd321

export CURR_DIR="${PWD}/"${CONT_L_HOSTNAME}/zimbra""
DIR="/opt/zimbra"

build:
	echo "Download zimbra..."
	wget -O opt/zimbra-install/zcs-rhel7.tgz  https://files.zimbra.com/downloads/8.8.9_GA/zcs-8.8.9_GA_2055.RHEL7_64.20180703080917.tgz
	mkdir -p ${CURR_DIR}/
	docker network create -d bridge --subnet 192.168.2.0/24 zimbra_bridge
	echo "Building docker image..."
	docker build -t ${IMAGE_NAME} .

run:
	@echo "Running docker container..."
	docker run -d --privileged --name "${CONT_NAME}" --hostname ${HOSTNAME} --net "${CONT_BRIDGE}" --ip "${CONT_IP}" \
	-e TERM="xterm" \
	-e "container=docker" \
	-e PASSWORD="${ZIMBRA_PASS}" \
	-e HOSTNAME="${CONT_S_HOSTNAME}" \
	-e DOMAIN="${CONT_DOMAIN}" \
	-e CONTAINERIP="${CONT_IP}" \
	-e NAME="${CONT_NAME}" \
	-v ${CURR_DIR}/:${DIR} \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-p 25:25 -p 80:80 -p 465:465 -p 587:587 -p 110:110 -p 143:143 -p 993:993 \
	-p 995:995 -p 443:443 -p 8080:8080 -p 8443:8443 -p 7071:7071 -p 9071:9071 \
    --sysctl net.core.somaxconn=65535 \
   	--sysctl net.ipv4.ip_local_port_range="10000 65535" \
	${IMAGE_NAME} /usr/sbin/init

stop:
	@echo "Stopping docker container..."
	docker stop ${CONT_NAME}

start:
	@echo "Starting docker container..."
	docker start ${CONT_NAME}

restart:
	@echo "Restarting docker container..."
	docker restart ${CONT_NAME}

rm:
	@echo "Removing docker container..."
	docker stop ${CONT_NAME}; docker rm -v ${CONT_NAME}

rmi:
	@echo "Removing docker image..."
	rm -rf ${CURR_DIR}
	docker stop ${CONT_NAME}; docker rm -v ${CONT_NAME}; docker rmi ${IMAGE_NAME}; docker rmi centos; docker network rm zimbra_bridge

exec:
	@echo "Entering to docker container..."
	docker exec -ti ${CONT_NAME} /bin/bash

