# Running local kubernetes cluster using Kind and Containerlab with cilium CNI

Kubernetes cluster integration with Containerlab based network devices for testing Cilium BGP Control plane functionality

## Requirements

- Docker
- Kind
- gomplate

## Notes

FRRouting based devices used by Containerlab topology uses custom image that is compiled with ECMP functionality enabled however the image is built only for `linux/arm64` architecture. If ECMP funtionality is not desired then official FRR image can be used that supports multiple platforms. It can be updated under `topology.gotmpl` file.

For MacOS (Apple Silicon), in order to run Containerlab as a container that does not provide ARM based image natively, `Use Rosetta for x86/amd64 emulation on Apple Silicon` experimental/beta feature must be enabled under docker desktop.

## Usage

```bash
make deploy
# do your thing
# when tired
make destroy
```

### Customization

There are few variables that can be customized during deployment. For example (default):

```yaml
KIND_NETWORK="172.100.0.0/16"
CLUSTER_NAME=bazzinga
CILIUM_VERSION=v1.13.0
```

and these can be customized by passing values to `make deploy` command e.g:

```bash
make deploy CLUSTER_NAME=whatever KIND_NETWORK=172.100.0.0/16 CILIUM_VERSION=v1.13.0
```

### Gateway API

Gateway API CRDs are installed by default. [HTTP Example](https://docs.cilium.io/en/v1.13/network/servicemesh/gateway-api/http/) from cilium can be deployed by executing:

```bash
kubectl kustomize gateway-api/examples | kubectl create -f -
```

Cluster topology also creates a bastion host that is connected to router0 in network topology. It acts as an external client and can be used for testing Ingress/Gateway/HTTPRoutes.

Reference: https://www.sobyte.net/post/2022-09/containerlab-kind-cilium-bgp
