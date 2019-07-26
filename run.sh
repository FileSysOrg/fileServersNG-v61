#!/bin/sh

export COMPOSE_FILE_PATH=${PWD}/target/classes/docker/docker-compose.yml

if [ -z "${M2_HOME}" ]; then
  export MVN_EXEC="mvn"
else
  export MVN_EXEC="${M2_HOME}/bin/mvn"
fi

start() {
    docker volume create fileserversng-v61-acs-volume
    docker volume create fileserversng-v61-db-volume
    docker volume create fileserversng-v61-ass-volume
    docker-compose -f $COMPOSE_FILE_PATH up --build -d
}

down() {
    docker-compose -f $COMPOSE_FILE_PATH down
}

purge() {
    docker volume rm fileserversng-v61-acs-volume
    docker volume rm fileserversng-v61-db-volume
    docker volume rm fileserversng-v61-ass-volume
}

build() {
    docker rmi alfresco-content-services-fileserversng-v61:development
    $MVN_EXEC clean install -DskipTests=true
}

tail() {
    docker-compose -f $COMPOSE_FILE_PATH logs -f
}

tail_all() {
    docker-compose -f $COMPOSE_FILE_PATH logs --tail="all"
}

test() {
    $MVN_EXEC verify
}

case "$1" in
  build_start)
    down
    build
    start
    tail
    ;;
  start)
    start
    tail
    ;;
  stop)
    down
    ;;
  purge)
    down
    purge
    ;;
  tail)
    tail
    ;;
  build_test)
    down
    build
    start
    test
    tail_all
    down
    ;;
  test)
    test
    ;;
  *)
    echo "Usage: $0 {build_start|start|stop|purge|tail|build_test|test}"
esac