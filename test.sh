#!/bin/bash




#simple case bash structure
# note in this case $case is variable and does not have to
# be named case this is just an example
case $1 in
    up) echo "You selected bash";;
    down) echo "You selected perl";;
    deploy) echo "You selected phyton";;
    tes) echo "You selected c++";;
    *)
        echo "Usage: deploy.sh [up|down|deploy|reload-haproxy|rollback]"
        exit 1
esac
