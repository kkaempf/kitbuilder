#
# Repository base class
#

require 'tmpdir'

module Kitbuilder
  class Repository
    def self.download pom
      basename = "#{pom.artifact}" + (pom.version ? "-#{pom.version}" : "") 
      pomfile = basename + ".pom"
      if File.exists?(pomfile)
#        puts "#{pomfile} exists"
        [true, pomfile]
      else
        uri = self.build_uri pom
#        puts "Repository download #{uri}"
        unless pom.version
          mavenname = "maven-metadata.xml"
          puts "Lookup latest version from #{mavenname}"
          result = nil
#          exit 1
#          begin            
#            Download.download(uri + "/#{mavenname}", mavenname )
#            File.open(mavenname) do |f|
#              xml = Nokogiri::XML(f)
#              dependency.version = xml.xpath("//latest")[0].text
#              result = self.download dependency
#            end
#          rescue
#            result = nil
#          ensure
#            File.unlink mavenname rescue nil
#          end
          return result
        end
        jarfile = basename + ".jar"
        testsfile = basename + "-test.jar"
        case Download.download(uri + "/#{pomfile}", pomfile)
        when :cached, :downloaded
          Download.download(uri + "/#{jarfile}", jarfile)
          Download.download(uri + "/#{testsfile}", testsfile)
          [false, pomfile]
        else
          nil
        end
      end
    end
  end
end
