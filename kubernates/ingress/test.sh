#!/bin/sh
k3d cluster delete test
k3d cluster create test --agents 1 -p "880:80@loadbalancer" -p "8443:443@loadbalancer" --k3s-server-arg '--no-deploy=traefik'

sleep 10

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.4/deploy/static/provider/baremetal/deploy.yaml

kubectl apply -f nginx-ingress-lb.yaml