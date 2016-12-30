#
# Download dependency from repo1.maven.org/maven2
#

require "kitbuilder/repository"

module Kitbuilder
  class Maven2 < Repository
    def self.build_uri dependency
      uri = "http://repo1.maven.org/maven2/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
