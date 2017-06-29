Gem::Specification.new do |spec|
  spec.name          = "shrine-google_drive_storage"
  spec.version       = "0.3.1"
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


  spec.files         = Dir["README.md", "LICENSE.txt", "lib/**/*.rb", "shrine-google_cloud_storage.gemspec"]
  
  spec.require_paths = "lib"

  spec.add_dependency 'shrine', '~> 2.2'
  spec.add_dependency 'google-api-client', '~> 0.13.0'

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "dotenv"
end
