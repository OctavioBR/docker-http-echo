.ONESHELL:
SHELL := /bin/bash
.PHONY: help deps run dist docker-* infra-*

REVISION ?= $(shell git describe --tags --always)
IMAGE    ?= http-echo:$(REVISION)

help: ## Show this help list
	@ grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

node_modules:
	npm install

deps: node_modules ## Install dependencies

run: deps ## Run local node server
	node index.js

dist: ## Build docker image
ifeq ($(shell docker images --quiet $(IMAGE)),)
	docker build --tag $(IMAGE) .
endif
	@echo "Image with tag $(REVISION) is already built"

docker-run: dist ## Run container locally
	docker run --name=http-echo \
	  --detach --publish=8080:80 \
	$(IMAGE)
	docker logs --follow http-echo

docker-stop: ## Stop and remove local container
	docker kill http-echo
	docker rm http-echo

infra-seed-ci-user: ## Generate PowerUser in AWS account and get it's access key to set in CI secrets
	aws --no-cli-pager iam create-user --user-name github
	aws --no-cli-pager iam attach-user-policy --user-name github \
	  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
	aws iam create-access-key --user-name github \
	  --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}'

terraform/.terraform:
	cd terraform
	terraform init

infra-up: terraform/.terraform ## Provision infrastructure resources
	cd terraform
	terraform apply -auto-approve

infra-down: terraform/.terraform ## Tear down infrastructure
	cd terraform
	terraform apply -destroy

infra-kubeconfig: ## Add auth data to kubeconfig allowing access to EKS cluster
	aws eks update-kubeconfig --region eu-west-2 --name green
