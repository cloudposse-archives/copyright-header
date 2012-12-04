#
# Copyright Header - A utility to manipulate copyright headers on source code files
# Copyright (C) 2012 Erik Osterman <e@osterman.com>
# 
# This file is part of Copyright Header.
# 
# Copyright Header is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Copyright Header is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Copyright Header.  If not, see <http://www.gnu.org/licenses/>.
#
require 'optparse'

module CopyrightHeader
  class MissingArgumentException < Exception; end

  class CommandLine
    attr_accessor :options, :parser, :optparse
    def initialize(options = {})
      begin
        @options = options
        @options[:base_path] ||= File.expand_path File.dirname(__FILE__) + "/../../"
        @optparse = OptionParser.new do |opts|
          opts.banner = "Usage: #{$0} options [file]"
          
          @options[:dry_run] ||= false
          opts.on( '-n', '--dry-run', 'Output the parsed files to STDOUT' ) do
            @options[:dry_run] = true
          end
          
          opts.on( '-o', '--output-dir DIR', 'Use DIR as output directory') do |dir|
            @options[:output_dir] = dir + '/'
          end
          
          opts.on( '--license-file FILE', 'Use FILE as header' ) do|file|
            @options[:license_file] = file
          end

          opts.on( '--license [' + Dir.glob(@options[:base_path] + '/licenses/*').map { |f| File.basename(f, '.erb') }.join('|') + ']', 'Use LICENSE as header' ) do|license|
            @options[:license] = license
          end

          opts.on( '--copyright-software NAME', 'The common name for this piece of software (e.g. "Copyright Header")' ) do|name|
            @options[:copyright_software] = name
          end

          opts.on( '--copyright-software-description DESC', 'The common name for this piece of software (e.g. "A utility to manipulate copyright headers on source code files")' ) do|desc|
            @options[:copyright_software_description] = desc
          end

          @options[:copyright_holders] ||= []
          opts.on( '--copyright-holder NAME', 'The common name for this piece of software (e.g. "Erik Osterman <e@osterman.com>"). Repeat argument for multiple names.' ) do|name|
            @options[:copyright_holders] << name
          end

          @options[:copyright_years] ||= []
          opts.on( '--copyright-year YEAR', 'The common name for this piece of software (e.g. "2012"). Repeat argument for multiple years.' ) do|year|
            @options[:copyright_years] << year
          end

          @options[:word_wrap] ||= 80
          opts.on( '-w', '--word-wrap LEN', 'Maximum number of characters per line for license (default: 80)' ) do |len|
            @options[:word_wrap] = len.to_i
          end

          opts.on( '-a', '--add-path PATH', 'Recursively insert header in all files found in path' ) do |path|
            @options[:add_path] = path
          end

          opts.on( '-r', '--remove-path PATH', 'Recursively remove header in all files found in path' ) do |path|
            @options[:remove_path] = path
          end

          @options[:syntax] ||= @options[:base_path] + '/contrib/syntax.yml'
          opts.on( '-c', '--syntax FILE', 'Syntax configuration file' ) do |path|
            @options[:syntax] = path
          end

          opts.on( '-V', '--version', 'Display version information' ) do
            puts "CopyrightHeader #{CopyrightHeader::VERSION}"
            puts "Copyright (C) 2012 Erik Osterman <e@osterman.com>"
            puts "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
            puts "This is free software: you are free to change and redistribute it."
            puts "There is NO WARRANTY, to the extent permitted by law."
            exit
          end

          opts.on( '-h', '--help', 'Display this screen' ) do
            puts opts
            exit
          end
        end

        @optparse.parse!

        # get the license_file from the shiped files
        @options[:license_file] ||= @options[:base_path] + '/licenses/' + @options[:license] + '.erb'

        unless @options.has_key?(:license_file)
          raise MissingArgumentException.new("Missing --license or --license-file argument")
        end

        unless File.file?(@options[:license_file])
          raise MissingArgumentException.new("Invalid --license or --license-file argument. Cannot open #{@options[:license_file]}")
        end
     
        if @options[:license]
          raise MissingArgumentException.new("Missing --copyright-software argument") if @options[:copyright_software].nil?
          raise MissingArgumentException.new("Missing --copyright-software-description argument") if @options[:copyright_software_description].nil?
          raise MissingArgumentException.new("Missing --copyright-holder argument") unless @options[:copyright_holders].length > 0
          raise MissingArgumentException.new("Missing --copyright-year argument") unless @options[:copyright_years].length > 0
        end
      rescue MissingArgumentException => e
        puts e.message
        puts @optparse
        exit (1)
      end
    end 

    def execute
      @parser = CopyrightHeader::Parser.new(@options)
      @parser.execute
    end
  end
end
