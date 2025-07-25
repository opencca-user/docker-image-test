 [![ci](https://github.com/opencca/opencca-build/actions/workflows/ci.yaml/badge.svg)](https://github.com/opencca/opencca-build/actions/workflows/ci.yaml)


# OpenCCA


### Getting Started

We currently are building OpenCCA in an x86-docker container. To get started, ensure to have the following
dependencies installed:

 > repo, git, make, docker

<details>
<summary>Prerequisite: Install git-repo tool</summary>

For installation methods see https://gerrit.googlesource.com/git-repo

```sh
# Manual installation:

mkdir -p ~/.bin
PATH="${HOME}/.bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
```


</details>  

<details>
<summary>Prerequisite: Install docker</summary>

For installation methods see https://docs.docker.com/engine/install/

```sh
# Docker on Ubuntu

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


sudo apt-get install docker-ce docker-ce-cli containerd.io \
             docker-buildx-plugin docker-compose-plugin
sudo chmod 777 /var/run/docker.sock
```

Verify installation:

```sh
docker run hello-world
```
</details>  

<details>
<summary>Prerequisite: Install make</summary>

```sh
# On Ubuntu
sudo apt install -y make
```

</details>

<details>
<summary>Prerequisite: Install git</summary>

```sh
# On Ubuntu
sudo apt install -y git
```

</details>



### Building OpenCCA
```
# Clone repositories
mkdir opencca opencca/snapshot && cd opencca
repo init -u git@github.com:opencca/opencca-manifest.git -b opencca/main -m systex25.xml 
repo sync --all

# Build and enter container
make -f opencca-build/docker/Makefile help
make -f opencca-build/docker/Makefile build
make -f opencca-build/docker/Makefile start
make -f opencca-build/docker/Makefile enter

# Build all components (inside container)
cd opencca-build/scripts/ && build_all.sh
```

Upon build completion, you find all build artifacts in /opencca/snapshot.
What's next is to flash the firmware on the hardware.
https://github.com/opencca/opencca-flash
