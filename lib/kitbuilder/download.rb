require 'open-uri'

module Kitbuilder
  class Download
    def self.download uri, target
      return true if File.exists?(target)
      begin        
        stream = open(uri)
        IO.copy_stream stream, target
        puts "#{target} downloaded to #{Dir.pwd}"
      rescue OpenURI::HTTPError
        return false
      end
      target
    end
  end
end
