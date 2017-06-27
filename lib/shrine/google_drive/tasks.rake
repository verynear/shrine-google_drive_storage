require "shrine/google_drive/rake"

namespace :google_drive do
  desc "Authorize Google Drive account: "
  task :authorize, [:client_secret_path, :application_name] do |_t, args|
    client_secret_path = args[:client_secret_path]
    application_name = args[:application_name]
    Shrine::GoogleDrive::Rake.authorize(client_secret_path, application_name)
  end
end
