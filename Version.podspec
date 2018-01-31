Pod::Spec.new do |s|
  s.name             = "Version"
  s.version          = "0.6.2"
  s.summary          = "Version represents and compares semantic versions in Swift."
  s.description      = <<-DESC
                       Version is a Swift Library, which enables to represent and compare semantic version numbers.
                       It follows [Semantic Versioning 2.0.0](http://semver.org).

                       The representation is:
                       * Comparable
                       * Equatable
                       * String Literal Convertible
                       * Printable
                       DESC
  s.homepage         = "https://github.com/mrackwitz/Version"
  s.license          = 'MIT'
  s.author           = { "Marius Rackwitz" => "git@mariusrackwitz.de" }
  s.source           = { :git => "https://github.com/mrackwitz/Version.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mrackwitz'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = 'Version/*.swift'
end
