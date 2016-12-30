#
# Kitbuilder::Dependency
#
#
require 'fileutils'
module Kitbuilder
  class Dependency
    attr_reader :group, :artifact, :scope
    attr_accessor :version
    def initialize group, artifact, version = nil, scope = nil
      @group = group
      @artifact = artifact
      @version = version
      @scope = scope

      @path = File.join(@group.split("."), @artifact)
      @path = File.join(@path, @version) if @version
    end
    def to_s
      "#{@group}:#{@artifact}" + (@version?":#{@version}":"")
    end
    #
    # resolve dependency by downloading pom/jar
    #
    # @return full path to .pom file
    #
    def resolve m2dir
      puts "\n\tResolving '#{self}'\n\tto #{m2dir.inspect}\n\t+ #{@path}"
      m2dir ||= "."
      Dir.chdir m2dir do
        FileUtils.mkdir_p @path
        Dir.chdir @path do
          pomfile = Maven2.download(self) || Bintray.download(self)
          puts "\n\t -> #{pomfile.inspect}"
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
