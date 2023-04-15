.DEFAULT_GOAL := help
.PHONY: help deps run dist docker/*

REVISION ?= $(shell git describe --tags --always)
IMAGE ?= http-echo:$(REVISION)

node_modules:
	npm install

help: ## Show this help list
	@ grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deps: node_modules ## Install dependencies

run: deps ## Run locally
	node index.js

dist: ## Build docker image
ifeq ($(shell docker images --quiet $(IMAGE)),)
	docker build --tag $(IMAGE) .
endif
	@echo "Image with tag $(REVISION) is already built"

docker/run: dist ## Run container locally (requires redis running on localhost)
	docker run --detach --expose 80:8080 \
		--name=http-echo \
	$(IMAGE)
	docker logs --follow http-echo

docker/stop: ## Stop and remove container
	docker kill http-echo
	docker rm http-echo
