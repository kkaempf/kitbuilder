#
# Kitbuilder::Dependency
#
#
require 'fileutils'

class DependencyExistsError < RuntimeError
end

module Kitbuilder
  class Dependency
    @@dependencies = []
    MAPPING = {
      "xerces-impl" => "xercesImpl"
    }
    attr_reader :group, :artifact, :scope, :optional
    attr_accessor :version

    def initialize parent, properties
#      puts "Dependency.new #{properties.inspect}"
      @parent = parent
      @group = properties[:group]
      artifact = properties[:artifact]
      @artifact = MAPPING[artifact] || artifact
      # treat "${foo.version}" as 'latest'
      version = properties[:version]
      @version = (version[0,1] == "$" ? nil : version) rescue nil
      if @@dependencies.include? self
        raise DependencyExistsError
      else
        @@dependencies << self
      end
      # test/compile/runtime
      @scope = properties[:scope]
      @optional = properties[:optional]
      @path = File.join(@group.split("."), @artifact)
      @path = File.join(@path, @version) if @version
    end
    def <=> other
      case other
      when Dependency
        ret = @group <=> other.group
        if ret == 0
          ret = @artifact <=> other.artifact
          if ret == 0
            ret = @version <=> other.version
          end
        end
        ret
      when Hash
        artifact = other[:artifact]
        artifact = MAPPING[artifact] || artifact
        version = other[:version]
        version = (version[0,1] == "$" ? nil : version) rescue nil
        ret = @group <=> other[:group]
        if ret == 0
          ret = @artifact <=> artifact
          if ret == 0
            @version <=> version
          end
        end
        ret
      else
        nil
      end
    end
    def self.find properties
      @@dependencies.include? properties
    end
    def test?
      @scope == "test"
    end
    def runtime?
      @scope == "runtime"
    end
    def compile?
      @scope == "compile"
    end
    def to_s
      s = "#{@group}:#{@artifact}" + (@version?":#{@version}":"")
      if @optional||@scope
        s += "<"
        s += "opt:" if @optional
        s += @scope if @scope
        s += ">"
      end
      if @parent
        s += " < #{@parent}"
      end
      s
    end
  end
end
