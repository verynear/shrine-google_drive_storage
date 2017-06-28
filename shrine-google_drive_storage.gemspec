# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "shrine/version"

Gem::Specification.new do |spec|
  spec.name          = "shrine-google_drive_storage"
  spec.version       = Shrine::GoogleDriveStorage::VERSION
  spec.authors       = ["Scott Near"]
  spec.email         = ["scott.a.near@gmail.com"]

  spec.summary       = "Provides Google Drive Storage for Shrine."
  spec.description   = "Provides Google Drive Storage for Shrine."
  spec.homepage      = "https://github.com/verynear/shrine-google_drive_storage"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  
  spec.require_paths = ["lib"]

  spec.add_dependency 'shrine', '~> 2.6', '>= 2.6.1'
  spec.add_dependency 'google-api-client', '~> 0.13.0'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "activerecord", "~> 4.2", ">= 4.2.0"
  spec.add_development_dependency "railties", "~> 4.2", ">= 4.2.0"
end
