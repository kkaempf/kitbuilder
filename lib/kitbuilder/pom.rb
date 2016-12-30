require 'nokogiri'

module Kitbuilder
  class Pom
    def initialize pomfile
      @file = pomfile
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
        yield Dependency.new group, artifact, version, scope
      end
      nil
    end
  end
end
