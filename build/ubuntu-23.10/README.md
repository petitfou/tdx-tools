
# Build TDX Stack on Ubuntu 23.10

Please run build script in Docker container via `./pkg-builder` to isolate the
build environment from the linux host. So you can build the TDX ubuntu packages
on any Linux OS. `./pkg-builder <build-script>` will automatically create a
Docker image named `pkg-builder-ubuntu-23.10` and start a container to run `<build-script>`

## Setup Docker

1. Follow https://docs.docker.com/engine/install/ to setup Docker.
2. Please add current user into docker group via `sudo usermod -G docker -a $USER`,
then restart docker service, or logout and login current user to take effect.

## Usages

1. Build all packages including host and guest

```
cd tdx-tools/build/ubuntu-23.10

./pkg-builder build-repo.sh
```

`build-repo.sh` will build host packages into host_repo/ and guest packages into guest_repo/ .

2. Build individual package


```
./pkg-builder intel-mvp-ovmf/build.sh
```
