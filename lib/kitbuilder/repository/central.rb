#
# Download dependency from http://central.maven.org/maven2
#

module Kitbuilder
  class Central < Repository
    def self.build_uri dependency
      uri = "http://central.maven.org/maven2/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
