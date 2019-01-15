# From the top directory, run the following:
#   make -f tools/docker/Makefile target

.PHONY: help
.PHONY: settings

DOCKERFILE ?= tools/docker/Dockerfile
DOCKER_ENV_FILE ?= tools/docker/docker.env

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`
DOCKER_IMAGE ?= $(APP_NAME):$(APP_VSN)-$(BUILD)
DOCKER_IMAGE_LATEST ?= `echo $(DOCKER_IMAGE) | sed 's/:.*/:latest/g'`
SKIP_PHOENIX ?= true
PORT ?= 8080

help:
	@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build -f $(DOCKERFILE) \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg SKIP_PHOENIX=$(SKIP_PHOENIX) \
		-t $(DOCKER_IMAGE) \
		-t $(DOCKER_IMAGE_LATEST) .

run: ## Run the app in Docker
	docker run --env-file $(DOCKER_ENV_FILE) \
		--expose $(PORT) -p $(PORT):$(PORT) \
		--rm -it $(DOCKER_IMAGE_LATEST)

settings:
	echo "APP_NAME = $(APP_NAME)" ; \
	echo "APP_VSN = $(APP_VSN)" ; \
	echo "BUILD = $(BUILD)" ; \
	echo "DOCKER_IMAGE = $(DOCKER_IMAGE)" ; \
	echo "DOCKER_IMAGE_LATEST = $(DOCKER_IMAGE_LATEST)" ; \
	echo "SKIP_PHOENIX = $(SKIP_PHOENIX)" ; \
	echo "PORT = $(PORT)" ; \
	echo ""

