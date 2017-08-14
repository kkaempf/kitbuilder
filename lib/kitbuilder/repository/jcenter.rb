#
# Download dependency from https://jcenter.bintray.com
#

module Kitbuilder
  class JCenter < Repository
    def self.build_uri dependency
      uri = "https://jcenter.bintray.com/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
