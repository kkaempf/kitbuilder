#
# Convert gradle cache to local maven repo
#

require 'find'

module Kitbuilder
  class Convert
    def initialize gradledir
      @gradledir = gradledir
    end
    def convert_to mavendir
      @mavendir = mavendir
      Find.find(@gradledir) do |path|
        next unless path =~ /\.pom$/
        pom = Pom.new path
        puts pom
      end
    end
  end
end
