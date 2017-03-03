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
        jars = []
        dir = File.dirname(File.dirname(path))
        puts "#{dir}:#{pom.basename}"
        # now look for jars        
        Find.find(dir) do |local|
          next unless local =~ /\.jar$/
          jars << local
        end
        dest = File.join(mavendir, pom.dirname)
        FileUtils.mkdir_p dest
        FileUtils.cp path, File.join(dest, "#{pom.basename}.pom")
        jars.each do |jar|
          puts "Dir #{dir}, jar #{jar}"
          FileUtils.cp jar, File.join(dest, "#{pom.basename}.jar")
        end
      end
    end
  end
end
