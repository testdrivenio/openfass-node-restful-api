# Deploy to Digital Ocean with Docker Swarm

> Get $10 in Digital Ocean credit [here](https://m.do.co/c/d8f211a4b4c2).

Create droplet:

```sh
$ docker-machine create \
  --driver digitalocean \
  --digitalocean-access-token ADD_YOUR_KEY \
  node;
```

Spin up [OpenFaas](https://www.openfaas.com/):

```sh
$ docker-machine ssh node -- docker swarm init --advertise-addr $(docker-machine ip node)
$ eval $(docker-machine env node)
$ git clone https://github.com/openfaas/faas && \
  cd faas && \
  ./deploy_stack.sh
```

Assuming you have an instance of Postgres running, create a new database along with a new table:

```sh
CREATE TABLE movie(id SERIAL, name varchar);
```

Rename *env-sample.yml* to *env.yml* and update the variables:

```yaml
environment:
  POSTGRES_USER: update
  POSTGRES_PASS: update
  POSTGRES_DB: update
  POSTGRES_HOST: update
```

Run a build with the [faas-cli](https://github.com/openfaas/faas-cli):

```sh
$ faas-cli build -f template.yml
```

Deploy:

```sh
$ faas-cli deploy -f template.yml -gateway=$(echo http://$(docker-machine ip node):8080)
```

Manually test:

```sh
$ curl -X POST $(echo http://$(docker-machine ip node):8080)/function/create -d \
  '{"name":"NeverEnding Story"}'

$ curl $(echo http://$(docker-machine ip node):8080)/function/read

$ curl -X POST $(echo http://$(docker-machine ip node):8080)/function/update -d \
  '{"name":"NeverEnding Story 2", "id": "1"}'

$ curl -X POST $(echo http://$(docker-machine ip node):8080)/function/delete -d \
  '{"id":"1"}'
```
