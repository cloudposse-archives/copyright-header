CopyrightHeader
===============


Features
------------

* Add/remove a copyright headers recursively on source files
* Customize the syntax configuration for how to write out comments

Caveats
-------
* Will only remove headers to files that have exactly the same header as the one we added
* Will only add headers to files which do not contain the pattern /[Cc]opyright|[Lc]icense/ in the first N lines

Requirements
------------

* Ruby 1.9.2 (supported version)

Installation & Usage
--------------------

    # gem install copyright_header
    # copyright-header --help

Add a GPL3 License header to a file:
    copyright-header --add-path /tmp/test.rb --license /tmp/GPL3.txt --dry-run

Remove the header created in the previous step (without --dry-run argument):
    copyright-header --remove-path /tmp/test.rb --license /tmp/GPL3.txt --dry-run

Paths can be either files or directories. It will recursively traverse the directory tree ignoring all dot files.

You can specify an alternative syntax configuration file using the --syntax argument.


Contact Information
-------------------

Erik Osterman <e@osterman.com>
http://www.osterman.com/

