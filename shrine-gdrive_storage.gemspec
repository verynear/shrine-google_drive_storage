Gem::Specification.new do |spec|
  spec.name          = "shrine-gdrive_storage"
  spec.version       = "0.5.0"
  spec.authors       = ["edwardsharp"]
  spec.email         = ["edward@edwardsharp.net"]
  spec.date          = '2018-04-04'
  spec.summary       = "Provides Google Drive Storage for Shrine."
  spec.description   = "Provides Google Drive Storage for Shrine. Fork & improvemnet on Scott Near's version (https://github.com/verynear/shrine-google_drive_storage)."
  spec.homepage      = "https://github.com/edwardsharp/shrine-gdrive_storage"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end


  spec.files         = Dir["README.md", "LICENSE.txt", "lib/**/*.rb", "shrine-gdrive_storage.gemspec"]
  
  spec.require_paths = "lib"

  spec.add_dependency 'shrine', '~> 2.1'
  spec.add_dependency 'googleauth', '~> 0.5'
  spec.add_dependency 'google-api-client', '~> 0.20.0'
  spec.add_development_dependency 'httparty', '~> 0.16'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'dotenv'
end
