# OpenFaaS RESTful API w/ Node and Postgres

Simple example of an [OpenFaaS](https://www.openfaas.com/) RESTful API.

## Getting Started

Build the Docker images for the functions:

```sh
$ sh build.sh
```

Initialize Swarm mode:

```sh
$ docker swarm init
```

Deploy:

```sh
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
$ curl -X POST http://localhost:8080/function/func_api-create -d \
  '{"name":"NeverEnding Story"}'

$ curl http://localhost:8080/function/func_api-read

$ curl -X POST http://localhost:8080/function/func_api-update -d \
  '{"name":"NeverEnding Story 2", "id": "1"}'

$ curl -X POST http://localhost:8080/function/func_api-delete -d \
  '{"id":"1"}'
```

## Deploy to Digital Ocean 

[deploy-swarm.md](deploy-swarm.md)
