#
# Download dependency from https://repository.jboss.org
#

module Kitbuilder
  class JBoss < Repository
    def self.build_uri dependency
      uri = "https://repository.jboss.org/nexus/content/repositories/thirdparty-releases" + dependency.group.split(".").join("/") + "/" + dependency.artifact
      if dependency.version
        uri += "/" + dependency.version
      end
      uri
    end
  end
end
