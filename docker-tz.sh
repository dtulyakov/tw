#!/bin/sh
######## SET
LANG=C
LC_ALL=C
GIT=$(which git)
ECHO=$(which echo)
USER=$(whoami)
DOCKER_IP=$(docker network inspect bridge | awk /Gateway/'{print $2}'|sed 's/\"//g')
START_DIR=$(pwd)

if [ $# = 0 ]; then
	${ECHO} Error - надо указать параметр
	exit 1

fi


if [ $1 = "build" ]; then
	docker build -t main-nginx .
	${ECHO} "Теперь можно запускать контейнеры"
	exit 0
fi

mkdir -p ${START_DIR}/tmp/vhosts/
cd ${START_DIR}

vmname=$@
######## SCRIPTS
for DNAME in ${vmname};
	do
	n=$(($n + 1))
	mkdir -p ${START_DIR}/tmp/${DNAME}
	${ECHO} "Hello ${DNAME}" > ${START_DIR}/tmp/${DNAME}/index.html
 	docker run --name ${DNAME} -v ${START_DIR}/tmp/${DNAME}:/usr/share/nginx/html -d -p 8${n}:80 main-nginx
##4 main nginx
cat > ${START_DIR}/tmp/vhosts/${DNAME} << _EOF
server {
	listen				80;
	server_name			${DNAME};
	reset_timedout_connection	on;
	charset UTF-8;
	location / {
		proxy_pass http://${DOCKER_IP}:8${n}/;
		proxy_set_header	Host		\$host;
		proxy_set_header	X-Forwarded-For	\$proxy_add_x_forwarded_for;
		proxy_redirect off;
		proxy_connect_timeout 30;
	}
}
_EOF
done


# run nginx proxy
docker run --name docker-nginx -v ${START_DIR}/tmp/vhosts:/etc/nginx/sites-enabled -d -p 80:80 main-nginx


# tests 
for DNAME in ${vmname};
	do
	curl ${DNAME}
done

#EOF
