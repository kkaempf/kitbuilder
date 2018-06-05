require 'open-uri'

module Kitbuilder
  class Download
    def self.exists? uri
      print "#{uri.inspect}\r"
      begin
        f = open(uri)
      rescue OpenURI::HTTPError
        return nil
      rescue URI::InvalidURIError
        STDERR.puts "\n\t  InvalidURIError"
        return nil
      rescue Exception => e
        STDERR.puts "\nopen(#{uri}) failed: #{e}"
        return nil
      end
      true
    end
    # lookup target in cache
    #  return :cached if cached
    #  return :downloaded if downloaded
    #  return nil if not found
    def self.download uri, target
      if File.exists?(target)
        puts "#{target} cached in #{Dir.pwd}"
        :cached 
      else
        begin
          stream = open(uri)
          IO.copy_stream stream, target
          puts "#{target} downloaded to #{Dir.pwd}"
        rescue OpenURI::HTTPError
          return nil
        rescue URI::InvalidURIError
          return nil
        end
        :downloaded
      end
    end
  end
end
