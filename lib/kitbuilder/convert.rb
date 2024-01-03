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
        dest = nil
        jars = []
        case path
        when /\.pom$/
          pom = Pom.new path
          dir = File.dirname(File.dirname(path))
#          puts "#{dir}:#{pom.basename}"
          # now look for jars or exes
          Find.find(dir) do |local|
            case local
            when /\.jar$/
            when /\.exe$/
              jars << local
            end
          end
          dest = File.join(mavendir, pom.dirname)
          FileUtils.mkdir_p dest
          FileUtils.cp path, File.join(dest, "#{pom.basename}.pom")
          jars.each do |jar|
            name = File.basename(jar)
#            puts "Dir #{dir}, jar #{jar}, name #{name}"
            FileUtils.cp jar, File.join(dest, name)
          end
        when /\.js$/
#          puts path
          # ... gradle/caches/modules-2/files-2.1/jquery/jquery.min/1.8.0/f3a55f44fb81cf8ee908a3872841f70d6548f8c1/jquery.min-1.8.0.js
          dirs = path.split "/"
          js = dirs.pop
          dirs.pop # drop checksum
          destdirs = dirs.pop(3)
          toplevels = destdirs.shift.split(".")
          dest = File.join(mavendir, (toplevels+destdirs).join("/"))
          puts "dest #{dest}, js #{js}"
          FileUtils.mkdir_p dest
          FileUtils.cp path, File.join(dest, js)
        end
      end
    end
  end
end
