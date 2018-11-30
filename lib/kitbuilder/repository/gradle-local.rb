#
# Download dependency from https://repo.gradle.org/gradle/libs-releases-local
#

module Kitbuilder
  class GradleLocal < Repository
    def self.build_uri dependency
      uri = "https://repo.gradle.org/gradle/libs-releases-local/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
