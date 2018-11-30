#
# Download dependency from https://dl.bintray.com/kotlin/kotlin-eap/
#

module Kitbuilder
  class KotlinEap < Repository
    def self.build_uri dependency
      uri = "https://dl.bintray.com/kotlin/kotlin-eap/" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
