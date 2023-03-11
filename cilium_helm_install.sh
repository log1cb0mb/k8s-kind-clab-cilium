#!/bin/sh
cilium-helm-install(){
    (
        set -e
        if [ -z "${1}" ]; then
            echo "version not provided"
            false
        fi
        printf "%0.s\e[34m=" {1..$COLUMNS}
        echo "\e[34mInstalling Cilium to cluster that kubectl currently points to"
        printf "%0.s\e[34m=" {1..$COLUMNS}
        ciliumVersion=${1}
        clusterName=${2}
        helm repo add cilium https://helm.cilium.io/
        cilium install \
          --version $ciliumVersion \
          --helm-set debug.enabled=false \
          --helm-set ipam.mode=cluster-pool-v2beta \
          --helm-set ipam.operator.clusterPoolIPv4PodCIDRList\[0\]="10.51.0.0/17" \
          --helm-set tunnel=disabled \
          --helm-set ipv4NativeRoutingCIDR="10.51.0.0/17" \
          --helm-set bgpControlPlane.enabled=true \
          --helm-set gatewayAPI.enabled=true \
          --helm-set kubeProxyReplacement="strict" \
          --helm-set k8sServiceHost=$clusterName-control-plane \
          --helm-set k8sServicePort="6443" \
          --helm-set bpf.masquerade=true \
          --helm-set ipMasqAgent.enabled=true \
          --helm-set ipMasqAgent.config.nomasq-all-reserved-ranges=true \
          --helm-set securityContext.privileged=true \
          --helm-set loadBalancer.mode=dsr
        #   --helm-set endpointRoutes.enabled=true
         #--set loadBalancer.acceleration=native
    )
}

cilium-deploy() {
    (
        set -e
        if [ -z "${1}" ]; then
            echo "version not provided"
            false
        fi
        cilium-helm-install ${1} ${2}
    )
}
