#--
# Copyright (c) 2016 SUSE LINUX Products GmbH
#
# Author: Klaus Kämpf <kkaempf@suse.de>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rubygems'
require 'kitbuilder/version'
require 'kitbuilder/convert'
require 'kitbuilder/dependency'
require 'kitbuilder/download'
require 'kitbuilder/pom'
require 'kitbuilder/repositories'

module Kitbuilder

  class Kitbuilder
    def initialize m2dir = nil, verbose = nil
      @m2dir = m2dir
      @verbose = verbose
      Pom.destination = @m2dir
      @notfound = []
    end
    # specify .jar to download
    def jar= j
      @jar = j
    end
    #
    # handle pom specification (download)
    #
    def handle pomspec, recursive=true
      puts "Handle #{pomspec.inspect}" if @verbose
      pom = Pom.new pomspec
      pom.jar = @jar
      pom.resolve recursive
    end
    #
    # convert gradle cache to maven cache
    #
    def gradle gradledir
      convert = Convert.new gradledir
      convert.convert_to @m2dir
    end

    def handle_dir dir, file, script
      base = File.basename(file, ".jar") # strip .jar
      base = File.basename(base, ".pom") # strip .pom
#      puts "handle #{base} in #{dir}"
      pom = Pom.new [dir, base], @verbose
      res = pom.find
#      puts "\n#{pom}.find => #{res.inspect}"
      uri = res[:uri]
      unless uri
        STDERR.puts "\n\e[31mNOT FOUND #{pom}\e[0m"
        @notfound << pom
        exit 1
      else
        puts "Found #{pom}\e[K"
      end
      script.puts "# #{pom}  #{uri}"
      script.puts "mkdir -p #{dir}"
      script.puts "pushd #{dir}"
      res.each do |k,v|
        next if k == :uri
        script.print "# " unless pom.wgets.include? k
        script.puts "wget -q #{uri}/#{v}"
      end
      script.puts "popd"
    end
    #
    # strip .jars from maven cache
    # write bash script to re-create
    #
    def strip bash_script
      @notfound = [] # collecting poms not found
      script = File.open(bash_script, "w+")
      raise "Can't open #{bash_script}" unless script
      # for each .jar in @m2dir do
      #   check if .pom exists
      #   read .pom
      #   find corresponding entry in maven universe
      #   write entry to bash scrip
      # done
      puts "Looking in #{@m2dir}" if @verbose
      script.puts "mkdir -p kit"
      script.puts "cd kit"
      kitdir = File.dirname @m2dir
      # find ant
      # find maven
      # find gradle
      Dir.foreach(kitdir) do |name|
        case name
        when /apache-ant-(\d+\.\d+.\d+)/
          version = $1
          STDERR.puts "ant version #{version}"
          script.puts "wget https://archive.apache.org/dist/ant/binaries/apache-ant-#{version}-bin.tar.bz2"
          script.puts "tar xf apache-ant-#{version}-bin.tar.bz2"
          script.puts "rm -f apache-ant-#{version}-bin.tar.bz2"
        when /apache-maven-(\d+\.\d+.\d+)/
          version = $1
          STDERR.puts "maven version #{version}"
          script.puts "wget https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/#{version}/apache-maven-#{version}-bin.tar.gz"
          script.puts "tar xf apache-maven-#{version}-bin.tar.gz"
          script.puts "rm -f apache-maven-#{version}-bin.tar.gz"
        when "jars", "m2", ".", "..", ".keep"
          # skip
        else
          STDERR.puts "\e[33mUnknown #{kitdir}/#{name}\e[0m"
        end
      end
      script.puts "mkdir -p m2"
      script.puts "cd m2"
      been_there = []
      Dir.chdir(@m2dir) do |d|
        Dir.glob("**/*.{jar,pom,signature}") do |f|
          dir = File.dirname(f)
#          puts "found #{f} in #{dir}"
          next if been_there.include? dir
          handle_dir dir, f, script
          been_there << dir
        end
      end
      script.puts "cd .."
      script.puts "cd .."
      @notfound.each do |pom|
        STDERR.puts "*** Pom not found: #{pom}"
      end
    end # def strip

  end # class

end # module
