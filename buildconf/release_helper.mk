#!/usr/bin/make -f

help: ## Print this help message
	@echo "Available make targets for $(firstword $(MAKEFILE_LIST)):"

	@# Print all targets with ## in help text
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*##/ \
		{printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	
	@echo ""
	@echo "Available variables for $(firstword $(MAKEFILE_LIST)):"
	@awk 'BEGIN {FS = " \\?= |##"} /^[A-Z0-9_-]+ \?= / \
		{printf "  \033[33m%-25s\033[0m %-5s \033[32m%s\033[0m \n", $$1, $$2, $$3}' $(MAKEFILE_LIST)


package: NAME=
package: DIR=
package: