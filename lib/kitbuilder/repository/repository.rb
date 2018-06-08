#
# Repository base class
#

require 'tmpdir'

module Kitbuilder
  class Repository
    #
    # build uri
    # *abstract*
    #
    def self.build_uri pom
      raise "Abstract Repository.build_uri called"
    end
    #
    # find in maven universe
    #
    #  returns pomfile, jarfile, sourcesfile
    def self.find pom
      res = nil
      basename = pom.basename
      pomfile = basename + ".pom"
      uri = self.build_uri pom
#      puts "repository.rb find uri #{uri.inspect}"
      if pom.version
        # get all relevant files
        pom.relevant_mapping.each do |symbol, suffix|
          file = basename + suffix
#          puts "check [#{symbol},#{suffix}] #{file.inspect}"
          if Download.exists?(uri + "/#{file}")
            res = {}
            res[:uri] = uri if res.empty?
            res[symbol] = file
          end
        end
      else
        mavenname = "maven-metadata.xml"
        puts "Lookup latest version from #{mavenname}"
      end
      res
    end

    def self.download pom
      basename = pom.basename
      pomfile = basename + ".pom"
      uri = self.build_uri pom
#        puts "Repository download #{uri}"
      unless pom.version
        mavenname = "maven-metadata.xml"
        puts "Lookup latest version from #{mavenname}"
        result = nil
#          exit 1
# EXPERIMENT: download maven-metadata.xml
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
        # could not determine version
        return result
      end
      jarfile = basename + ".jar"
      testfile = basename + "-test.jar"
      testsfile = basename + "-tests.jar"
      javadocfile = basename + "-javadoc.jar"
        
      case Download.download(uri + "/#{pomfile}", pomfile)
      when :cached, :downloaded
        Download.download(uri + "/#{jarfile}", jarfile)
        Download.download(uri + "/#{testfile}", testfile)
        Download.download(uri + "/#{testsfile}", testsfile)
        Download.download(uri + "/#{javadocfile}", javadocfile)
        sourcesfile = nil
        if pom.with_sources
          have_source = false
          [ "-sources.jar", "-source-release.zip"].each do |suffix|
            sourcesfile = basename + suffix
            if Download.download(uri + "/#{sourcesfile}", sourcesfile)
              have_source = true
              puts "Sourcesfile #{sourcesfile}"
              break
            end
          end
          unless have_source
            STDERR.puts "*** Can't download source for #{pom}:#{jarfile}"
            sourcesfile = nil
          end
          [false, pomfile, sourcesfile]
        else
          [false, pomfile]
        end
      else
        nil
      end # case
    end # def self.download
  end # class
end # module
