# Grabs the list of packages from pyproject.toml
PACKAGES := $(shell for pkg in `grep -o "\.\./\.\./.*" pyproject.toml | sed -e 's/"//g'`; do echo $$pkg; done)

.PHONY: all
.DEFAULT_GOAL = help

.PHONY: clean
clean: ## Remove coverage, requirements, pytest cache, distribution, and reports directories
	rm -f .coverage
	rm -f requirements.txt
	rm -rf .pytest_cache
	rm -rf dist
	rm -rf reports
	rm -f poetry.lock

.PHONY: dist-clean
dist-clean: clean ## Remove all build and test artifacts and the virtual environment
	rm -rf .venv

.PHONY: build
build: ## Create the virtual environment and install development dependencies
	python -m poetry install

.PHONY: update
update: ## Update dependencies
	python -m poetry update

.PHONY: test
test: ## Execute test cases
	python -m poetry run pytest

.PHONY: cover
cover: ## Execute test cases and produce coverage reports
	python -m poetry run pytest --cov . --junitxml reports/xunit.xml \
		--cov-report xml:reports/coverage.xml --cov-report term-missing

.PHONY: ssap
ssap: ## Generates requirements.txt file
	@echo "Generating requirements.txt..."
	python -m poetry export --without-hashes --with dev -o requirements.txt
	@echo "requirements.txt content:"
	@cat requirements.txt

.PHONY: collect-wheels
collect-wheels: ## Collects all wheels under a single folder
	@mkdir -p dist/wheels
	@for pkg in $(PACKAGES); do cp $$pkg/dist/*.whl dist/wheels; done
	cp dist/*.whl dist/wheels


.PHONY: package
package: package-build collect-wheels ## Create applications deployable zip packages for each application
	@mkdir -p dist/package-exploded dist/package
	$(eval WHEELS=$(shell ls dist/wheels))
	@cd dist/wheels && \
	pip install --platform manylinux2014_x86_64 --only-binary=:all: --implementation cp --target ../package-exploded --find-links . $(WHEELS)
	@cd dist/package-exploded && \
	zip -x "*__pycache__*" -x "*dist-info*" -r ../package/applications.zip .


.PHONY: package-build
package-build:
	python -m poetry build

.PHONY: help
help: ## Show make target documentation
	@awk -F ':|##' '/^[a-zA-Z0-9_\-]+:.*##/ { \
	printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)
