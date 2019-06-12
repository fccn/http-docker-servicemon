# import deploy config
# You can change the default deploy config with `make dpl="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# grep the version from the mix file
VERSION=$(shell ./version.sh)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
image: ## Build the image using cache
	docker build -t $(APP_NAME) $(BUILD_ARGS) .

build-nc: ## Build the image without caching
	docker build --no-cache -t $(APP_NAME) $(BUILD_ARGS) .

shell: image ## Run a shell in a new container created from image
	docker run -a stdin -a stdout -i -t --rm --name "http_monitor" -p $(HOST_PORT):$(HOST_PORT) -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=/bin/sh $(APP_NAME)

dev-shell: image ## Run a shell in new container and attach source files
	docker run -a stdin -a stdout -i -t --rm --name "http_monitor" -p $(HOST_PORT):$(HOST_PORT) -v /var/run/docker.sock:/var/run/docker.sock -v $(PWD)/monitor-docker.sh:/monitor-docker.sh -v $(PWD)/src:/app --entrypoint=/bin/sh $(APP_NAME)

run: image ## Run this image
	docker run -i -t --rm --name "http_monitor" -p $(HOST_PORT):$(HOST_PORT) -v /var/run/docker.sock:/var/run/docker.sock $(APP_NAME)

test: image ## Check if image was correctly built
	docker run -i -t --rm --name "http_monitor_test" -v /var/run/docker.sock:/var/run/docker.sock --entrypoint="/test-monitor.sh" $(APP_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` and `latest` tagged containers to repository

# Docker publish
publish: publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to repository

publish-latest: tag-latest ## Publish the `latest` tagged container to ECR
	@echo 'publish latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` tagged container to ECR
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

publish-dev: tag-dev ## Publish the development container tagged with `dev-{version}` and `dev-latest` to ECR
	@echo 'publish dev-$(VERSION) and dev-latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):dev-$(VERSION)
	docker push $(DOCKER_REPO)/$(APP_NAME):dev-latest

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

tag-dev: ## Generate development container `dev-{version}` and `dev-latest` tag
	@echo 'create tags dev-$(VERSION) and dev-latest'
	docker tag $(DEV_APP_NAME) $(DOCKER_REPO)/$(APP_NAME):dev-$(VERSION)
	docker tag $(DEV_APP_NAME) $(DOCKER_REPO)/$(APP_NAME):dev-latest

version: ## Output the current version
	@echo $(VERSION)

#test: image ## run a test container with the image
#	docker run -i -t -d -v $(pwd)/test/www:/app/html -p 10443:443 $(APP_NAME):latest
