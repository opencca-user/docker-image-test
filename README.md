# OpenCCA

### Getting Started

We build opencca in a docker container. To get started, ensure to have the following
dependencies installed:

Docker, git, repo, make

<details>
<summary>Prerequisites: Install git-repo tool</summary>
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
<summary>Prerequisite: Install Docker</summary>

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


```
# Clone repositories
mkdir opencca && cd opencca
repo init -u git@github.com:opencca/opencca-manifest.git -b opencca/main -m default.xml 
repo sync -j$(nproc) --all

repo start aster --all

# Build container
cd opencca-build/docker/
make build

# Start container
make -f opencca-build/docker/Makefile start

# Enter container
make -f opencca-build/docker/Makefile enter

# in container: build all components
cd opencca-build/scripts/ && build_all.sh
```

