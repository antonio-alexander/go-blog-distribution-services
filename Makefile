## ----------------------------------------------------------------------
##
## ----------------------------------------------------------------------

version=`cat ./version.json | jq '.version' | sed 's/"//g'`
git_branch=`git rev-parse --abbrev-ref HEAD`
git_commit=`git rev-parse HEAD`

.PHONY: help

# REFERENCE: https://stackoverflow.com/questions/16931770/makefile4-missing-separator-stop
help: ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

check-jq: ## check jq installation
	@which jq || echo "jq not installed"

check-nssm: ## check nssm installation
	@which nssm || echo "nssm not installed"

build-windows: ## build sample_application
	@GOOS=windows go build -o ./tmp/sample_application.exe -ldflags "-X github.com/antonio-alexander/go-blog-distribution-services/cmd/internal.Version=${version} -X github.com/antonio-alexander/go-blog-distribution-services/cmd/internal.GitCommit=${git_commit} -X github.com/antonio-alexander/go-blog-distribution-services/cmd/internal.GitBranch=${git_branch}" ./cmd/main.go

build-linux: ## build sample_application
	@go build -o ./tmp/sample_application -ldflags "-X github.com/antonio-alexander/go-blog-distribution-services/cmd/internal.Version=${version} -X github.com/antonio-alexander/go-blog-distribution-services/cmd/internal.GitCommit=${git_commit} -X github.com/antonio-alexander/go-blog-distribution-services/cmd/internal.GitBranch=${git_branch}" ./cmd/main.go

clean: ## clean any dependencies
	@rm ./tmp/sample_application*

install-windows: build-windows ## install windows service using nssm
	@cd tmp
	@../install.bat

uninstall-windows: ## uninstall windows service using nssm
	@cd tmp
	@../uninstall.bat
