#
# Download dependency from https://repository.sonatype.org/content/groups/sonatype-public-grid
#

module Kitbuilder
  class Sonatype < Repository
    def self.build_uri dependency
      uri = "https://repository.sonatype.org/content/groups/sonatype-public-grid/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
