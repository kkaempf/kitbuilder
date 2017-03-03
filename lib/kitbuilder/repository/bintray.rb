#
# Download dependency from https://bintray.com
#

module Kitbuilder
  class Bintray < Repository
    def self.build_uri dependency
      uri = "https://bintray.com/android/android-tools/download_file?file_path=" + dependency.group.split(".").join("%2F") + "%2F" + dependency.artifact
      if dependency.version
        uri += "%2F" + dependency.version
      end
      uri
    end
  end
end
