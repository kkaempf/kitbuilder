#
# Kitbuilder::Dependency
#
#
require 'fileutils'

class DependencyExistsError < RuntimeError
end

module Kitbuilder
  class Dependency
    @@groups = Hash.new
    MAPPING = {
      "xerces-impl" => "xercesImpl"
    }
    attr_reader :group, :artifact, :scope, :optional
    attr_accessor :version
    private
    def exists?
      versions = @@groups[@group][@artifact] rescue nil
      case versions
      when nil then false
      when Array then versions.include? @version
      when Dependency then versions
      else
        false
      end
    end
    public
    def initialize parent, properties
      @parent = parent
      @group = properties[:group]
      artifacts = @@groups[group] || Hash.new
      artifact = properties[:artifact]
      @artifact = MAPPING[artifact] || artifact
      # treat "${foo.version}" as 'latest'
      version = properties[:version]
      @version = (version[0,1] == "$" ? nil : version) rescue nil
      if exists?
        raise DependencyExistsError
      end
      versions = artifacts[@artifact] ||= Hash.new
      if @version
        versions[@version] = self
      else
        artifacts[@artifact] = self
      end
      @@groups[group] = artifacts
      # test/compile/runtime
      @scope = properties[:scope]
      @optional = properties[:optional]
      @path = File.join(@group.split("."), @artifact)
      @path = File.join(@path, @version) if @version
    end
    def self.find properties
      puts "Dependency.find #{properties.inspect}"
      artifacts = @@groups[properties[:group]]
      puts "Dependency.find artifacts #{artifacts.inspect}"
      return nil unless artifacts
      versions = artifacts[properties[:artifact]]
      puts "Dependency.find versions #{versions.inspect}"
      dependency = case versions
                   when nil
                     nil
                   when Array
                     versions[properties[:version]]
                   when Dependency
                     versions
                   else
                     nil
                   end
      puts "Dependency.find dependency #{dependency.inspect}"
      dependency
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
    #
    # resolve dependency by downloading pom/jar
    #
    # @return full path to .pom file
    #
    def resolve m2dir
#      puts "\n\tResolving '#{self}'\n\tto #{m2dir.inspect}\n\t+ #{@path}"
      if @group[0,1] == "$"
        puts "\tCan't resolve group #{@group.inspect}"
        return
      end
      m2dir ||= "."
      Dir.chdir m2dir do
        FileUtils.mkdir_p @path
        Dir.chdir @path do
          pomfile = Maven2.download(self) || Bintray.download(self) || Gradle.download(self)
#          puts "\n\t -> #{pomfile.inspect}"
          if pomfile
            File.expand_path(File.join(m2dir, @path, pomfile))
          else
            STDERR.puts "*** Download of #{self} failed"
          end
        end
      end
    end
  end
end
