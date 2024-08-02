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
        files = []
        case path
        # caches/modules-2/files-2.1/org.gradle.toolchains/foojay-resolver/0.8.0/4a3a39d3b507c3c93d04130c7246113428272cf3/foojay-resolver-0.8.0.pom
        when /\.pom$/
          pom = Pom.new path
          # dir: two levels up
          dir = File.dirname(File.dirname(path))
          # caches/modules-2/files-2.1/org.gradle.toolchains/foojay-resolver/0.8.0
          # puts "POM #{dir}:#{pom.basename}"
          # now look for files below caches/modules-2/files-2.1/org.gradle.toolchains/foojay-resolver/0.8.0/...
          Find.find(dir) do |local|
            case local
            when /\.asc$/, /\.exe$/, /\.gz$/, /\.jar$/, /\.module$/, /\.zip$/
              files << local
            end
          end
          dest = File.join(mavendir, pom.dirname)
          FileUtils.mkdir_p dest
          FileUtils.cp path, File.join(dest, "#{pom.basename}.pom")
          files.each do |file|
            name = File.basename(file)
            # puts "DIR #{dir}, file #{file}, name #{name}"
            FileUtils.cp file, File.join(dest, name)
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
          # puts "dest #{dest}, js #{js}"
          FileUtils.mkdir_p dest
          FileUtils.cp path, File.join(dest, js)
        end
      end
    end
  end
end
