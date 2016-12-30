require 'nokogiri'

module Kitbuilder
  class Pom
    def initialize pomfile, parent_dep = nil
      @file = pomfile
      @parent = parent_dep
      begin
        File.open(pomfile) do |f|
          begin
            @xml = Nokogiri::XML(f)
            @xmlns = @xml.xpath("//project").empty? ? "xmlns:" : ""
          rescue Exception => e
            STDERR.puts "Error parsing #{pomfile}: #{e}"
            raise
          end
        end
      rescue Exception => e
        STDERR.puts "Error reading #{pomfile}: #{e}"
        raise
      end
    end
    def to_s
      @file
    end
    def dependencies
      @xml.xpath("//#{@xmlns}dependency").each do |d|
        group = d.xpath("#{@xmlns}groupId")[0].text
        artifact = d.xpath("#{@xmlns}artifactId")[0].text
        version = d.xpath("#{@xmlns}version")[0].text rescue nil
        scope = d.xpath("#{@xmlns}scope")[0].text rescue nil
        optional = d.xpath("#{@xmlns}optional")[0].text rescue nil
        begin
          yield Dependency.new @parent, { group: group, artifact: artifact, version: version, scope: scope, optional: optional }
        rescue DependencyExistsError
          STDERR.puts "\n\t*** Loop"
        end
      end
      nil
    end
  end
end
