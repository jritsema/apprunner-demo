app := apprunner-demo

all: help

.PHONY: help
help: Makefile
	@echo
	@echo " Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## start: run local project
.PHONY: start
start:
	node .

## image: build code into a container image and push it to ECR
.PHONY: image
image:
	./build.sh ${app}

## apprunner: create App Runner service using Terraform
.PHONY: apprunner 
apprunner: image
	cd iac; \
	terraform init; \
	terraform apply -var="app=${app}" -var="repository_url=$(shell cat ecr-repo)" -auto-approve

## destroy: tear down infrastructure
.PHONY: destroy
destroy:
	cd iac; \
	terraform destroy -var="app=${app}" -var="repository_url=$(shell cat ecr-repo)" -auto-approve; \
	aws ecr delete-repository --force --repository-name ${app}
