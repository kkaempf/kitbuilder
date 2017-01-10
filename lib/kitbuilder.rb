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
require 'kitbuilder/pom'
require 'kitbuilder/dependency'
require 'kitbuilder/download'
require 'kitbuilder/maven2'
require 'kitbuilder/bintray'
require 'kitbuilder/gradle'

module Kitbuilder

  class Kitbuilder
    def initialize m2dir = nil
      @m2dir = m2dir
    end
    def handle pomspec, parent_dep
      puts "Handle #{pomspec.inspect}"
      case pomspec
      when nil
        # nothing
      when Pom
        pomspec.dependencies do |dep|
          next unless dep.runtime?
          handle dep.resolve(@m2dir), dep
        end
      when /\.pom/
        # .pom file
        pom = Pom.new pomspec, parent_dep
        pom.dependencies do |dep|
          next unless dep.runtime?
          handle dep.resolve(@m2dir), dep
        end
      when /([^:]+):([^:]+)(:(.+))?/
        # pom spec com.android.tools.lint:lint:25.2.0-beta2
        dep = Dependency.new parent_dep, { group: $1, artifact: $2, version: ($3 ? $4 : nil) }
        handle dep.resolve(@m2dir), dep
      else
        STDERR.puts "Can't handle pomspec #{pomspec.inspect}"
        raise
      end
    end
  end

end
