#!/bin/bash

set -o errexit

KIND_NETWORK="kind"
KIND_SUBNET=${1}


kind_network () {
    (
    	if [ ! "$(docker network ls | grep kind)" ]; then
            echo "Creating kind network..."
            docker network create "${KIND_NETWORK}" \
            -d bridge --subnet ${1} \
            -o "com.docker.network.bridge.enable_ip_masquerade"="true" \
            -o "com.docker.network.driver.mtu"="1500"
    	else
    	echo "kind network already exists."
    	fi
    )

}

create_kind_network() {
    (
        set -e
        if [ -z "${1}" ]; then
            echo "Network address not provided"
            false
        fi
        kind_network ${1}
    )
}
