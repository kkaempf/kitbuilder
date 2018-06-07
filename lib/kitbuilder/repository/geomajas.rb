#
# Download dependency from http://maven.geomajas.org
#

module Kitbuilder
  class GeoMajas < Repository
    def self.build_uri dependency
      uri = "http://maven.geomajas.org/nexus/content/groups/public/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
