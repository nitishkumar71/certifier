#!/bin/sh

if ! [ -x "$(command -v docker)" ]; then
  echo 'Unable to find docker command, please install Docker (https://www.docker.com/) and retry' >&2
  exit 1
fi

export IP=127.0.0.1
export USER_NAME=$(whoami)
export KUBECONFIG=/home/$USER_NAME/.kube/config

# setup k3s using k3sup
sudo curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
mkdir -p $KUBECONFIG
k3sup install --ip $IP --user $USER_NAME
cp ./kubeconfig $KUBECONFIG
k3sup app install openfaas

# run test in k3s
kubectl port-forward -n openfaas svc/gateway 8080:8080 &
export OPENFAAS_URL=http://$IP:8080/
make test-kubernetes