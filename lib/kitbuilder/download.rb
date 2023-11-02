require 'open-uri'

module Kitbuilder
  class Download
    def self.exist? uri
      print "#{uri.inspect}\e[K\r" # erase to end of line, back to column 0
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
    def self.download uri, target, verbose = nil
      if File.exist?(target)
        puts "#{target} cached in #{Dir.pwd}"
        :cached 
      else
        begin
          stream = URI.open(uri)
          IO.copy_stream stream, target
          puts "#{target} downloaded to #{Dir.pwd} from #{uri}"
          return :downloaded
        rescue SocketError => e
          STDERR.puts "*** HTTPError: #{uri} (#{e})" if verbose
        rescue OpenURI::HTTPError => e
          STDERR.puts "*** HTTPError: #{uri} (#{e})" if verbose
        rescue URI::InvalidURIError => e
          STDERR.puts "*** InvalidURI: #{uri} (#{e})" if verbose
        rescue OpenSSL::SSL::SSLError => e
          STDERR.puts "*** SSLError: #{uri} (#{e})" if verbose
        end
        nil
      end
    end
  end
end
