#!/bin/sh

set -o errexit

CLUSTER_NAME=${1}

echo "> Deleting Kind cluster..."
kind delete cluster --name=$CLUSTER_NAME

echo "> Deleting clab topology..."
running="$(docker inspect -f '{{.State.Running}}' containerlab 2>/dev/null || true)"
if [ "${running}" == 'true' ]; then
  cid="$(docker inspect -f '{{.ID}}' containerlab)"
  echo "> Stopping and deleting Containerlab container..."
  docker exec -it containerlab clab destroy -t topology.yaml
  docker stop $cid >/dev/null
fi
