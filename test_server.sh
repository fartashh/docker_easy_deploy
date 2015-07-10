#!/bin/bash


while true; do
    printf "%s | %s\n" "$(date)" "$(curl -si 192.168.59.103:8080 | grep HTTP)"
    sleep 0.2
done