#
# Repository base class
#

require 'tmpdir'

module Kitbuilder
  class Repository
    def self.download dependency
      basename = "#{dependency.artifact}" + (dependency.version ? "-#{dependency.version}" : "") 
      pomfile = basename + ".pom"
      if File.exists?(pomfile)
#        puts "#{pomfile} exists"
        pomfile
      else
        uri = self.build_uri dependency
        puts "Repository download #{uri}"
        unless dependency.version
          mavenname = "maven-metadata.xml"
          puts "Lookup latest version from #{mavenname}"
          result = nil
          begin            
            Download.download(uri + "/#{mavenname}", mavenname )
            File.open(mavenname) do |f|
              xml = Nokogiri::XML(f)
              dependency.version = xml.xpath("//latest")[0].text
              result = self.download dependency
            end
          rescue
          ensure
            File.unlink mavenname rescue nil
          end
          return result
        end
        jarfile = basename + ".jar"
        if Download.download(uri + "/#{pomfile}", pomfile)
          Download.download(uri + "/#{jarfile}", jarfile)
          pomfile
        else
          nil
        end
      end
    end
  end
end
