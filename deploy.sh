#!/bin/bash

set -e

DOCKER_HOST_NAME="myapp_hostname"

if [[ -z "$DOCKER_HUB_USER" ]]; then
    DOCKER_HUB_USER="fartashh"
fi

APP_IMAGE="myapp"
REMOTE_IMAGE=${DOCKER_HUB_USER}/${APP_IMAGE}

IMAGE_TAG=$(date | sed 's/ /_/g' | sed 's/:/_/g')

TAGGED_IMAGE=${REMOTE_IMAGE}:${IMAGE_TAG}

NUM_BACKUPS=2
APP_CONTAINER="appname_container"
NGINGX_CONTAINER="appname_nginx_container"
NGINGX_IMAGE="${DOCKER_HUB_USER}/nginx"

MESSAGE_FILENAME=msg.txt

print_deployed_msg () {
    cat ${MESSAGE_FILENAME}
}


run_app_containers_from_image () {


    for i in {0..1}; do
        PORT=780${i}

        docker stop ${APP_CONTAINER}_${i} &>/dev/null || true
        docker rm ${APP_CONTAINER}_${i} &>/dev/null || true

        docker run -d \
            -e SRV_NAME=s${i} \
            --name=${APP_CONTAINER}_${i} \
            -p ${PORT}:5000 \
            --link redis:redis \
            --link mongodb:mongodb \
            $1

        # give app a second to come back up
        sleep 2
    done
}

build_push_app_server_tagged_image () {
    cd app_server
    echo ${TAGGED_IMAGE}
    docker build -t ${TAGGED_IMAGE} .
    # if you want to use docker hub uncomment the following line go to 149
    #docker push ${TAGGED_IMAGE}
    cd ..
}

build_mongodb(){
    cd mongodb
    docker build -t ${APP_IMAGE}/mongodb .
    cd ..
}

build_redis(){
    cd redis
    docker build -t ${APP_IMAGE}/redis .
    cd ..
}

build_nginx(){
    cd nginx
    docker build -t ${APP_IMAGE}/nginx .
    cd ..
}

#build_ekl(){
#    cd ekl
#    docker build -t ${APP_IMAGE}/ekl .
#    cd ..
#}



case $1 in
    up)
        # Run the nginx, mongo, redis container
        echo  "stop and remove all container"
        RUNING_PROCESS=$(docker ps -a -q)
        if [[ -z "$RUNING_PROCESS" ]];then
        echo "There is no container"
        else
        docker stop $(docker ps -a -q)
        docker rm $(docker ps -a -q)
        echo "All container removed"
        fi

        docker run -d  \
            --net host \
            --name ${NGINGX_CONTAINER} \
            ${APP_IMAGE}/nginx

        # start "database"
        docker run -d \
            --name redis \
            ${APP_IMAGE}/redis

        docker run -d \
            --name mongodb \
            ${APP_IMAGE}/mongodb

#        docker run -d \
#            -p 5601:80
#            --name ekl \
#            ${APP_IMAGE}/ekl

        ;;
    down)
        echo "under construction"
        ;;
    build)
        # Run it for forst time to build the docker images from Dockerfiles
#        build_nginx
        build_mongodb
        build_redis
        #build_ekl
    ;;
    deploy)
        # deploy project

        build_push_app_server_tagged_image
        # if you want to use docker hub uncomment the following line
        #docker pull ${TAGGED_IMAGE}

        run_app_containers_from_image ${TAGGED_IMAGE}
        print_deployed_msg
        echo "Accessible at " $(boot2docker ip ${DOCKER_HOST_NAME})":8080"
        ;;
    reload-nginx)
        echo "Reloading Nginx Container"
        docker stop ${NGINGX_CONTAINER}
        docker rm ${NGINGX_CONTAINER}
        docker run -d  \
            --net host \
            --name ${NGINGX_CONTAINER} \
            ${APP_IMAGE}/nginx

        echo "Accessible at " $(boot2docker ip ${DOCKER_HOST_NAME})":8080"
        ;;
    rollback)
        echo "Rollback app server to " ${REMOTE_IMAGE}:$2
        run_app_containers_from_image ${REMOTE_IMAGE}:$2
        ;;
    *)
        echo "Usage: deploy.sh [build|up|deploy|reload-nginx|rollback]"
        exit 1
esac
