COPYRIGHT_CMD ?= copyright-header
#COPYRIGHT_CMD ?= docker run --rm --volume `pwd`:$(COPYRIGHT_OUTPUT_DIR) osterman/copyright-header
COPYRIGHT_LICENSE ?= GPL3
COPYRIGHT_HOLDER ?= Erik Osterman <e@osterman.com>
COPYRIGHT_YEAR ?= 2012-2016
COPYRIGHT_SOFTWARE ?= Copyright Header
COPYRIGHT_SOFTWARE_DESCRIPTION ?= A utility to manipulate copyright headers on source code files
COPYRIGHT_OUTPUT_DIR ?= /usr/src
COPYRIGHT_WORD_WRAP ?= 100

remove-copyright:
	$(COPYRIGHT_CMD) \
    --license $(COPYRIGHT_LICENSE)  \
    --remove-path lib/:bin/ \
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
    --add-path lib/:bin/ \
    --guess-extension \
    --copyright-holder '$(COPYRIGHT_HOLDER)' \
    --copyright-software '$(COPYRIGHT_SOFTWARE)' \
    --copyright-software-description '$(COPYRIGHT_SOFTWARE_DESCRIPTION)' \
    --copyright-year $(COPYRIGHT_YEAR) \
    --word-wrap $(COPYRIGHT_WORD_WRAP) \
    --output-dir $(COPYRIGHT_OUTPUT_DIR)


