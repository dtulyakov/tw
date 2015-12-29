#!/bin/sh
######## SET
LANG=C
LC_ALL=C
GIT=$(which git)
USER=$(whoami)
${GIT} clone https://github.com/dtulyakov/tw.git /home/${USER}/DOCKER
GIT_DIR="/home/${USER}/DOCKER/"
GIT_PROJ=$(ls ${GIT_DIR}|grep -v 'tz.sh')


######## SCRIPTS
for PROJ in ${GIT_PROJ};
	do
	cd	${GIT_DIR}${PROJ}
	docker build -t test-${PROJ} .
done


docker run --name docker-alice -d -p 81:80 test-docker-alice
docker run --name docker-bob -d -p 82:80 test-docker-bob
docker run --name docker-tom  -d -p 83:80 test-docker-tom
docker run --name docker-nginx -d -p 80:80 test-docker-nginx

#EOF
