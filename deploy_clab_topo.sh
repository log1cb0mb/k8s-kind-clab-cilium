#!/bin/sh
set -o errexit

# create containerlab container unless it already exists
container_name='containerlab'
running="$(docker inspect -f '{{.State.Running}}' "${container_name}" 2>/dev/null || true)"
if [ "${running}" == 'true' ]; then 
  echo "Containerlab already UP!";
else
  docker run -d --rm -it --privileged \
    --platform=linux/amd64 \
    --name "${container_name}" \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /run/netns:/run/netns \
    --pid="host" \
    -w $PWD \
    -v $PWD:$PWD \
    ghcr.io/srl-labs/clab bash
fi

# build containerlab topology for cluster
export CLUSTER_NAME=${1}
gomplate -d cluster_name=env:"CLUSTER_NAME" -f topology.gotmpl > topology.yaml

# create containerlab topology unless it already exists
docker exec -it "${container_name}" clab inspect -t topology.yaml | grep 'no containers found' &> /dev/null
if [ $? == 0 ]; then
  docker exec -it "${container_name}" clab deploy --reconfigure -t topology.yaml;
fi
