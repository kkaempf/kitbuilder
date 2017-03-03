#
# Download dependency from https://plugins.gradle.org/m2/
#

module Kitbuilder
  class Gradle < Repository
    def self.build_uri dependency
      uri = "https://plugins.gradle.org/m2/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
