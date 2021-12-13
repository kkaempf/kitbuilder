#
# Download dependency from http://dbis-halvar.uibk.ac.at/artifactory/libs-release/
#

module Kitbuilder
  class DbisHalvar < Repository
    def self.build_uri dependency
      uri = "http://dbis-halvar.uibk.ac.at/artifactory/libs-release/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
