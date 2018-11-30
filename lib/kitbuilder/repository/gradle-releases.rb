#
# Download dependency from https://repo.gradle.org/gradle/libs-releases
#

module Kitbuilder
  class GradleReleases < Repository
    def self.build_uri dependency
      uri = "https://repo.gradle.org/gradle/libs-releases/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
