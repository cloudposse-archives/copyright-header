CopyrightHeader
===============


Features
------------

* Add/remove a copyright headers recursively on source files
* Customize the syntax configuration for how to write out comments
* Built-in support for GPL3 and MIT licenses
* Supports custom licenes with --license-file argument
* ERB template support

Caveats
-------
* Will only remove headers to files that have exactly the same header as the one we added
* Will only add headers to files which do not contain the pattern /[Cc]opyright|[Lc]icense/ in the first N lines


Requirements
------------

* Ruby 1.9.2 (supported version)

Installation & Usage
--------------------

    # gem install copyright-header
    # copyright-header --help

Add a GPL3 License header to a file:

    copyright-header --add-path /tmp/test.rb --license GPL3 --dry-run

Remove the header created in the previous step (without --dry-run argument):

    copyright-header --remove-path /tmp/test.rb --license GPL3 --dry-run

Paths can be either files or directories. It will recursively traverse the directory tree ignoring all dot files.

You can specify an alternative syntax configuration file using the --syntax argument.


Full list of supported arguments:

    Usage: copyright-header options [file]
        -n, --dry-run                    Output the parsed files to STDOUT
        -o, --output-dir DIR             Use DIR as output directory
            --license-file FILE          Use FILE as header
            --license [GPL3|MIT]         Use LICENSE as header
            --copyright-software NAME    The common name for this piece of software (e.g. "Copyright Header")
            --copyright-software-description DESC
                                         The common name for this piece of software (e.g. "A utility to manipulate copyright headers on source code files")
            --copyright-holder NAME      The common name for this piece of software (e.g. "Erik Osterman <e@osterman.com>"). Repeat argument for multiple names.
            --copyright-year YEAR        The common name for this piece of software (e.g. "2012"). Repeat argument for multiple years.
        -w, --word-wrap LEN              Maximum number of characters per line for license (default: 80)
        -a, --add-path PATH              Recursively insert header in all files found in path
        -r, --remove-path PATH           Recursively remove header in all files found in path
        -c, --syntax FILE                Syntax configuration file
        -V, --version                    Display version information
        -h, --help                       Display this screen


Contact Information
-------------------

Erik Osterman <e@osterman.com>
http://www.osterman.com/

