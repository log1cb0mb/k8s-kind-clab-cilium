SHELL := /bin/bash

KIND_NETWORK?=172.100.0.0/16
CLUSTER_NAME?=bazzinga
CILIUM_VERSION=v1.13.0
export CLUSTER_NAME:=$(CLUSTER_NAME)

create_kind_network:
	@source ./kind_network.sh && create_kind_network $(KIND_NETWORK)

deploy_cluster: create_kind_network
	@if ! which kind > /dev/null; then echo "kind needs to be installed"; exit 1; fi
	@if ! kind get clusters | grep $(CLUSTER_NAME) > /dev/null; then \
		kind create cluster \
		  --name $(CLUSTER_NAME) \
		  --config cluster.yaml; fi
	./deploy_clab_topo.sh $(CLUSTER_NAME)
	kubectl apply -f ./cm_cordns.yaml
	@$(MAKE) gateway_api_crds_install
	@$(MAKE) deploy_cilium

gateway_api_crds_install:
		kubectl kustomize gateway-api/crds-gateway-api | kubectl create -f -

cilium_helm_install:
	@source ./cilium_helm_install.sh && cilium-deploy $(CILIUM_VERSION) $(CLUSTER_NAME)

deploy_cilium: cilium_helm_install
	@$(MAKE) cilium_install_post

cilium_install_post:
	gomplate -d cluster_name=env:CLUSTER_NAME -d topology_vars.yaml -f cilium-bgp-peering-policies.gotmpl | kubectl apply -f -
	kubectl apply -f cilium-lb-ippool.yaml

deploy: deploy_cluster

destroy:
	 ./teardown.sh $(CLUSTER_NAME)

.PHONY: destroy cilium_install_post deploy_cilium cilium_helm_install deploy_cluster
