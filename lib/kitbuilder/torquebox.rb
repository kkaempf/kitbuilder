#
# Download dependency from http://rubygems-proxy.torquebox.org/releases
#

require "kitbuilder/repository"

module Kitbuilder
  class Sonatype < Repository
    def self.build_uri dependency
      uri = "http://rubygems-proxy.torquebox.org/releases/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
