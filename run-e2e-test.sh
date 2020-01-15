#!/bin/sh

if ! [ -x "$(command -v docker)" ]; then
  echo 'Unable to find docker command, please install Docker (https://www.docker.com/) and retry' >&2
  exit 1
fi

export IP=127.0.0.1
export USER_NAME=$(whoami)
# setup docker swarm 
docker swarm init
git clone https://github.com/openfaas/faas.git
./faas/deploy_stack.sh --no-auth

# run test in docker swarm
export OPENFAAS_URL=http://$IP:8080/
make test-swarm

# remove docker swarm, once tests complete
docker swarm leave --force

# setup k3s using k3sup
sudo curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
k3sup install --ip $IP --user $USER_NAME
k3sup app install openfaas

# run test in k3s
export OPENFAAS_URL=http://$IP:31112/
make test-kubernetes