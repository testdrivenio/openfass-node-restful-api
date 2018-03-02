# Deploy to Digital Ocean

> Get $10 in Digital Ocean credit [here](https://m.do.co/c/d8f211a4b4c2).

This guide looks at how to deploy a Serverless API to Digital Ocean with OpenFaaS.

Pick an orchestrator:

1. Docker Swarm
1. Kubernetes

## Docker Swarm

*Check out the [video](https://youtu.be/ru_hg9I5mwM) as well.*

### Steps

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
$ faas-cli deploy -f template.yml --gateway=$(echo http://$(docker-machine ip node):8080)
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

## Kubernetes

^83He$@zh3wm

### Steps

Create a new *Ubuntu 16.04.3 x64* droplet on [Digital Ocean](https://m.do.co/c/d8f211a4b4c2).

SSH into the box and then run following commands to install Docker along with kubeadm, kubelet and kubernetes-cni:

```sh
$ apt-get update && apt-get install -y apt-transport-https
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
$ echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
$ apt-get update && apt-get install -qy docker.io
$ apt-get update && apt-get install -y kubelet kubeadm kubernetes-cni
```

Create a new user:

```sh
$ adduser michael
$ usermod -aG sudo michael
$ su - michael
```

Deploy Kubernetes:


```sh
$ sudo kubeadm init
```

```sh
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Install overlay network:

```sh
$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

Allow containers to be placed on the master:

```sh
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

Deploy OpenFaaS:

```sh
$ git clone https://github.com/openfaas/faas-netes
$ cd faas-netes/
$ kubectl apply -f ./namespaces.yml,./yaml
```

Navigate to [http://<YOUR_IP>:31112](http://<YOUR_IP>:31112) to view the OpenFaaS dashboard.

Clone down the API:

```sh
$ cd ~
$ git clone https://github.com/testdrivenio/openfass-node-restful-api.git
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

Install the CLI:

```sh
$ curl -sL https://cli.openfaas.com | sudo sh
```

Run a build with the [faas-cli](https://github.com/openfaas/faas-cli):

```sh
$ sudo faas-cli build -f template.yml
```

Deploy:

```sh
$ sudo faas-cli deploy -f template.yml --gateway=http://<YOUR_IP>:31112
```

Manually test:

```sh
$ curl -X POST http://<YOUR_IP>:31112/function/create -d \
  '{"name":"NeverEnding Story"}'

$ curl http://<YOUR_IP>:31112/function/read

$ curl -X POST http://<YOUR_IP>:31112/function/update -d \
  '{"name":"NeverEnding Story 2", "id": "1"}'

$ curl -X POST http://<YOUR_IP>:31112/function/delete -d \
  '{"id":"1"}'
```
