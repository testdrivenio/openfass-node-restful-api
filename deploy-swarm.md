# Deploy to Digital Ocean via Docker Swarm

> Get $10 in Digital Ocean credit [here](https://m.do.co/c/d8f211a4b4c2).

This guide looks at how to deploy a Serverless API to Digital Ocean with OpenFaaS and Docker Swarm mode.

### Steps

Create droplet:

```sh
$ docker-machine create \
  --driver digitalocean \
  --digitalocean-access-token ADD_YOUR_KEY \
  node;

$ docker-machine env node
$ eval $(docker-machine env node)
```

Build the Docker images for the functions:

```sh
$ sh build.sh
```

Spin up and deploy [OpenFaas](https://www.openfaas.com/):

```sh
$ docker-machine ssh node \
    -- docker swarm init \
    --advertise-addr $(docker-machine ip node)

$ docker stack deploy func --compose-file docker-compose.yml --prune
```

Create database and `movie` table:

```sh
$ PG_CONTAINER_ID=$(docker ps --filter name=movies-db --format "{{.ID}}")
$ docker exec -ti $PG_CONTAINER_ID psql -U postgres -W
# CREATE DATABASE movies;
# \c movies
# CREATE TABLE movie(id SERIAL, name varchar);
# \q
```

Test:

```sh
$ curl -X POST \
    $(echo http://$(docker-machine ip node):8080)/function/func_api-create -d \
    '{"name":"NeverEnding Story"}'

$ curl $(echo http://$(docker-machine ip node):8080)/function/func_api-read

$ curl -X POST \
    $(echo http://$(docker-machine ip node):8080)/function/func_api-update -d \
    '{"name":"NeverEnding Story 2", "id": "1"}'

$ curl -X POST \
    $(echo http://$(docker-machine ip node):8080)/function/func_api-delete -d \
    '{"id":"1"}'
```
