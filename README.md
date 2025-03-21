# OpenCCA

### Getting Started

```
# Clone repositories
mkdir opencca && cd opencca
repo init -u git@github.com:opencca/opencca-manifest.git -m default.xml

# Build container
make -f opencca-build/docker/Makefile build

# Enter container
make -f opencca-build/docker/Makefile enter

# in container: build all components
cd opencca-build/scripts/ && build_all.sh
```

