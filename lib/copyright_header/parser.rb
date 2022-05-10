#
# Copyright Header - A utility to manipulate copyright headers on source code files
# Copyright (C) 2012-2016 Erik Osterman <e@osterman.com>
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
require 'fileutils'
require 'yaml'
require 'erb'
require 'ostruct'
require 'linguist'

module CopyrightHeader
  class FileNotFoundException < Exception; end
  class ExistingLicenseException < Exception; end
  class EmptyFileException < Exception; end

  class License
    @lines = []
    def initialize(options)
      @options = options
      @lines = load_template.split(/\n/).map { |line| line += "\n" }
    end

    def word_wrap(text, max_width = nil)
      max_width ||= @options[:word_wrap]
      text.gsub(/(.{1,#{max_width}})(\s|\Z)/, "\\1\n")
    end

    def load_template
      if File.exists?(@options[:license_file])
        template = ::ERB.new File.new(@options[:license_file]).read, 0, '%'
        license = template.result(OpenStruct.new(@options).instance_eval { binding })
        license = word_wrap(license)
        license
      else
        raise FileNotFoundException.new("Unable to open #{file}")
      end
    end

    def format(comment_open = nil, comment_close = nil, comment_prefix = nil)
      comment_open ||= ''
      comment_close ||= ''
      comment_prefix ||= ''
      license = comment_open + @lines.map { |line| (comment_prefix + line).gsub(/\s+\n$/, "\n") }.join() + comment_close
      license.gsub!(/\\n/, "\n")
      license
    end
  end

  class Header
    @file = nil
    @contents = nil
    @config = nil

    def initialize(file, config)
      @file = file
      @contents = File.read(@file)
      @config = config
    end

    def format(license)
      license.format(@config[:comment]['open'], @config[:comment]['close'], @config[:comment]['prefix'])
    end

    def add(license)
      if has_copyright?
        raise ExistingLicenseException.new("detected existing license")
      end

      copyright = self.format(license)
      if copyright.nil?
        STDERR.puts "Copyright is nil"
        return nil
      end

      if @contents.strip.empty?
        raise EmptyFileException.new("file is empty")
      end

      text = ""
      if @config.has_key?(:after) && @config[:after].instance_of?(Array)
        copyright_written = false
        lines = @contents.split(/\n/, -1)
        head = lines.shift(10)
        while(head.size > 0)
          line = head.shift
          text += line + "\n"
          @config[:after].each do |regex|
            pattern = Regexp.new(regex)
            if pattern.match(line)
              text += copyright
              copyright_written = true
              break
            end
          end
        end
        if copyright_written
          text += lines.join("\n")
        else
          text = copyright + text + lines.join("\n")
        end
      else
        # Simply prepend text
        text = copyright + @contents
      end
      return text
    end

    def remove(license)
      if has_copyright?
        text = self.format(license)
        # Due to editors messing with whitespace, we'll make this more of a fuzzy match and use \s to match whitespace
        pattern = Regexp.escape(text).gsub(/\\[ n]/, '\s*').gsub(/\\s*$/, '\s')
        exp = Regexp.new(pattern)
        @contents.gsub!(exp, '')
        @contents
      else
        STDERR.puts "SKIP #{@file}; copyright not detected"
        return nil
      end
    end

    def has_copyright?(lines = 10)
      @contents.split(/\n/)[0..lines].select { |line| line =~ /(?!class\s+)([Cc]opyright|[Ll]icense)\s/ }.length > 0
    end
  end

  class Syntax
    attr_accessor :guess_extension

    def initialize(config, guess_extension = false)
      @guess_extension = guess_extension
      @config = {}
      syntax = YAML.load_file(config)
      syntax.each_value do |format|
        format['ext'].each do |ext|
          @config[ext] = {
            :before => format['before'],
            :after => format['after'],
            :comment => format['comment']
          }
        end
      end
    end

    def ext(file)
      extension = File.extname(file)
      if @guess_extension && (extension.nil? || extension.empty?)
        extension = Linguist::FileBlob.new(file).language.extensions.first
      end
      return extension
    end

    def supported?(file)
      @config.has_key? ext(file)
    end

    def header(file)
      Header.new(file, @config[ext(file)])
    end
  end

  class Parser
    attr_accessor :options
    @syntax = nil
    @license = nil
    def initialize(options = {})
      @options = options
      @exclude = [ /^LICENSE(|\.txt)$/i, /^holders(|\.txt)$/i, /^README/, /^\./]
      @license = License.new(:license_file => @options[:license_file],
                             :copyright_software => @options[:copyright_software],
                             :copyright_software_description => @options[:copyright_software_description],
                             :copyright_years => @options[:copyright_years],
                             :copyright_holders => @options[:copyright_holders],
                             :word_wrap => @options[:word_wrap])
      @syntax = Syntax.new(@options[:syntax], @options[:guess_extension])
    end

    def execute
      if @options.has_key?(:add_path)
        @options[:add_path].split(File::PATH_SEPARATOR).each { |path| add(path) }
      end

      if @options.has_key?(:remove_path)
        @options[:remove_path].split(File::PATH_SEPARATOR).each { |path| remove(path) }
      end
    end

    def transform(method, path)
      paths = []
      if File.file?(path)
        paths << path
      else
        paths << Dir.glob("#{path}/**/*")
      end

      paths.flatten!

      paths.each do |path|
        begin
          if File.file?(path)
            if File.basename(path).match(Regexp.union(@exclude))
              STDERR.puts "SKIP #{path}; excluded"
              next
            end
          elsif File.directory?(path)
            next
          else
            STDERR.puts "SKIP #{path}; not file"
            next
          end

          if @syntax.supported?(path)
            header = @syntax.header(path)
            contents = header.send(method, @license)
            if contents.nil?
              STDERR.puts "SKIP #{path}; failed to generate license"
            else
              write(path, contents)
            end
          else
            STDERR.puts "SKIP #{path}; unsupported #{@syntax.ext(path)}"
          end
        rescue Exception => e
          STDERR.puts "SKIP #{path}; exception=#{e.message}"
        end
      end
    end

    # Add copyright header recursively
    def add(dir)
      transform(:add, dir)
    end

    # Remove copyright header recursively
    def remove(dir)
      transform(:remove, dir)
    end

    def write(file, contents)
      if @options[:dry_run]
        STDERR.puts "UPDATE #{file} [dry-run]"
        STDERR.puts contents
      elsif @options[:output_dir].nil?
        STDERR.puts "UPDATE #{file} [no output-dir]"
        STDERR.puts contents
      else
        dir = "#{@options[:output_dir]}/#{File.dirname(file).gsub(/^\/+/, '')}"
        STDERR.puts "UPDATE #{file} [output-dir #{dir}]"
        FileUtils.mkpath dir unless File.directory?(dir)
        output_path = @options[:output_dir] + "/" + file
        f =File.new(output_path, 'w')
        f.write(contents)
        f.close
      end
    end
  end
end
