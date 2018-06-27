SHELL := /bin/bash

# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md docs/terraform.md

-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

## Lint terraform code
lint:
	$(SELF) terraform/install terraform/get-modules terraform/get-plugins terraform/lint terraform/validate
#COPYRIGHT_CMD ?= copyright-header
COPYRIGHT_CMD ?= docker run --rm --volume `pwd`:$(COPYRIGHT_OUTPUT_DIR) osterman/copyright-header:latest
COPYRIGHT_LICENSE ?= GPL3
COPYRIGHT_HOLDER ?= Erik Osterman <e@osterman.com>
COPYRIGHT_YEAR ?= 2012-2017
COPYRIGHT_SOFTWARE ?= Copyright Header
COPYRIGHT_SOFTWARE_DESCRIPTION ?= A utility to manipulate copyright headers on source code files
COPYRIGHT_OUTPUT_DIR ?= /usr/src
COPYRIGHT_WORD_WRAP ?= 100
COPYRIGHT_PATHS ?= lib/:bin/:contrib/

remove-copyright:
	$(COPYRIGHT_CMD) \
	  --license $(COPYRIGHT_LICENSE)  \
	  --remove-path $(COPYRIGHT_PATHS) \
	  --guess-extension \
	  --copyright-holder '$(COPYRIGHT_HOLDER)' \
	  --copyright-software '$(COPYRIGHT_SOFTWARE)' \
	  --copyright-software-description '$(COPYRIGHT_SOFTWARE_DESCRIPTION)' \
	  --copyright-year $(COPYRIGHT_YEAR) \
	  --word-wrap $(COPYRIGHT_WORD_WRAP) \
	  --output-dir $(COPYRIGHT_OUTPUT_DIR)

add-copyright:
	$(COPYRIGHT_CMD) \
	  --license $(COPYRIGHT_LICENSE)  \
	  --add-path $(COPYRIGHT_PATHS) \
	  --guess-extension \
	  --copyright-holder '$(COPYRIGHT_HOLDER)' \
	  --copyright-software '$(COPYRIGHT_SOFTWARE)' \
	  --copyright-software-description '$(COPYRIGHT_SOFTWARE_DESCRIPTION)' \
	  --copyright-year $(COPYRIGHT_YEAR) \
	  --word-wrap $(COPYRIGHT_WORD_WRAP) \
	  --output-dir $(COPYRIGHT_OUTPUT_DIR)


bump:
	gem bump

release:
	rake release
