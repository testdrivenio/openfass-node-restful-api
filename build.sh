#!/bin/sh

docker build -t mjhea0/faas-api-create ./functions/api-create
docker build -t mjhea0/faas-api-read ./functions/api-read
docker build -t mjhea0/faas-api-update ./functions/api-update
docker build -t mjhea0/faas-api-delete ./functions/api-delete
