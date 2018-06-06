require 'nokogiri'

module Kitbuilder
  class Pom
    attr_reader :file, :group, :artifact, :scopes, :version, :parent, :with_sources

    MAPPING = {
      "xerces-impl" => "xercesImpl"
    }
    #
    # set download directory
    #
    def self.destination= m2dir
      @@m2dir = m2dir
    end
    # getter
    def self.destination
      @@m2dir
    end

    #
    # find in maven universe
    #
    #  returns pomfile, jarfile, sourcesfile
    def find
      Maven2.find(self) || Central.find(self) || JCenter.find(self) || Bintray.find(self) || Gradle.find(self) || Torquebox.find(self)
    end
    #
    # download pom from maven universe
    #  returns cached, pomfile, sourcesfile
    def download
      Maven2.download(self) || Central.download(self) || JCenter.download(self) || Bintray.download(self) || Gradle.download(self) || Torquebox.download(self)
    end
    #
    #
    # download pom/jar
    #
    # @return full path to .pom file
    #
    def download_to path, with_sources = nil
      if @group[0,1] == "$"
        puts "\tCan't resolve group #{@group.inspect}"
        return
      end
      @with_sources = with_sources
      join = cached = sourcesfile = nil
      Dir.chdir @@m2dir do
        FileUtils.mkdir_p path
        Dir.chdir path do
          cached, pomfile, sourcesfile = self.download
          case pomfile
          when ::String
            join = File.join(@@m2dir, path, pomfile)
            # can't expand_path here !
          else
            return nil
          end
        end
      end
      [cached, File.expand_path(join), sourcesfile]
    end
    #
    # parse a .pom file
    #
    def parse file
      begin
        File.open(file) do |f|
          begin
            @xml = Nokogiri::XML(f).root
            namespaces = @xml.namespaces
            @xmlns = (namespaces["xmlns"])?"xmlns:":""
          rescue Exception => e
            STDERR.puts "Error parsing pom #{file}: #{e}"
            raise
          end
        end
      rescue Exception => e
        STDERR.puts "Error reading pom #{file}: #{e}"
        raise
      end
    end

    def parent= parent
      @parent = parent
    end
    def jar= jar
      @jar = jar
    end
    #
    # Pom representation
    #
    def initialize pomspec, verbose = nil
      @verbose = verbose
      artifact = nil
      case pomspec
      when Pom
        @group = pomspec.group
        artifact = pomspec.artifact
        @version = pomspec.version
        @scopes = pomspec.scopes
        @optional = pomspec.optional
      when Hash
        @group = pomspec[:group]
        artifact = pomspec[:artifact]
        @version = pomspec[:version]
        @scopes = pomspec[:scopes]
        @optional = pomspec[:optional]
      when /\.pom/ # File
        parse pomspec
        project = @xml.xpath("/#{@xmlns}project")
        @group = project.xpath("#{@xmlns}groupId")[0].text.strip rescue project.xpath("#{@xmlns}parent/#{@xmlns}groupId")[0].text.strip
        artifact = project.xpath("#{@xmlns}artifactId")[0].text.strip
        @version = project.xpath("#{@xmlns}version")[0].text.strip rescue project.xpath("#{@xmlns}parent/#{@xmlns}version")[0].text.strip
        @file = pomspec
      when /\.jar/ # File
        dirs = pomspec.to_s.split('/')
        dirs.pop # .jar file
        @version = dirs.pop
        artifact = dirs.pop
        @group = dirs.join('.')
#        puts "Pom.new(#{pomspec}) -> #{@group}:#{artifact}:#{@version}"
      when /:/
        specs = pomspec.to_s.split(':')
        @group = specs.shift
        artifact = specs.shift
        @version = specs.pop # version is always last
        @scopes = specs
#        puts "@group #{@group.inspect}, artifact #{artifact.inspect}, @scopes  #{@scopes.inspect}, @version #{@version.inspect}"
      else
        STDERR.puts "Unrecognized pomspec >#{pomspec.inspect}<"
      end
      @artifact = MAPPING[artifact] || artifact
    end
    #
    # Compare
    #
    def <=> other
      ret = @group <=> other.group
      if ret == 0
        ret = @artifact <=> other.artifact
        if ret == 0
          ret = @version <=> other.version
        end
      end
      ret
    end
    #
    # scope accessors
    #
    def test?
      @scopes.include? "test"
    end
    def runtime?
      @scopes.include? "runtime"
    end
    def compile?
      @scopes.include? "compile"
    end
    #
    # String representation
    #
    def to_s
      s = "#{@group}:#{@artifact}" + (@version?":#{@version}":"")
      if @optional||@scopes
        s += "<"
        s += "opt:" if @optional
        s += @scopes if @scopes
        s += ">"
      end
      if @parent
        s += " < #{@parent}"
      end
      s
    end
    #
    # basename of .pom or .jar file
    #
    def basename
      basename = "#{@artifact}" + (@version ? "-#{@version}" : "") 
    end
    #
    # dirname of .pom of .jar file (in maven)
    #
    def dirname
      path = File.join(@group.split("."), @artifact)
      path = File.join(path, @version) if @version
      path
    end
    #
    # dependencies
    #
    def dependencies
      @xml.xpath("//#{@xmlns}dependency | //#{@xmlns}parent").each do |d|
        group = d.xpath("#{@xmlns}groupId")[0].text
        artifact = d.xpath("#{@xmlns}artifactId")[0].text
        version = d.xpath("#{@xmlns}version")[0].text rescue nil
        scope = d.xpath("#{@xmlns}scope")[0].text rescue nil
        optional = d.xpath("#{@xmlns}optional")[0].text rescue nil
        pom = Pom.new( { group: group, artifact: artifact, version: version, scopes: scope, optional: optional } )
#        puts "dependency pom #{pom.inspect}"
        yield pom
      end
    end
    #
    # resolve a pom
    # - download it
    # - download associated jars
    # - resolve dependencies
    #
    def resolve
#      puts "Resolving #{self}"
      # does it exist ?
      cached, result = download_to dirname
      if cached
        puts "Exists"
      else
        if result.is_a?(::String)
#          puts "Downloaded to #{result}"
        else
          puts "Failed download #{self}"
          return
        end
      end
      parse result
      dependencies do |pom|
        pom.parent = self
#        pom.resolve
      end
    end
  end
end
