modules = $(shell ls -1 */*.tf | xargs -I % dirname %)

bootstrap:
	@terraform get

test:
	@for m in $(modules); do (terraform validate "$$m" && echo "√ $$m") || exit 1 ; done
	@(terraform validate . && echo "√ .") || exit 1

.PHONY: test bootstrap
