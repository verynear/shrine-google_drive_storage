require 'google/apis/drive_v3'
require 'googleauth'
require 'shrine/google_drive/session'

module Shrine
  module GoogleDrive
    module Rake
      extend self
      ##
      # Ensure valid credentials, either by restoring from the saved credentials
      # files or intitiating an OAuth2 authorization. If authorization is required,
      # the user's default browser will be launched to approve the request.
      #
      # @param client_secret_path [ String ] with the location of the JSON file downloaded from Google console
      # @param application_name [ String ] given in the Google console > credentials > OAuth 2.0 client IDs section
      # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
      def authorize(client_secret_path, application_name)
        client = Shrine::GoogleDrive::Session.from_config(client_secret_path, application_name: application_name)
        # # List the 10 most recently modified files.
        # response = client.list_files(page_size: 10, fields: 'nextPageToken, files(id, name)')
        # puts 'Files:'
        # puts 'No files found' if response.files.empty?
        # response.files.each do |file|
        #   puts "#{file.name} (#{file.id})"
        # end
        if client
          puts "\nAuthorization completed.\n\n"
          puts "The credentials were saved into #{ client_secret_path}.\n"
          puts "You can use these credentials as follows: \n"
          puts "Shrine::GoogleDrive::Session.from_config(#{client_secret_path}, application_name: #{application_name})"
          puts "\n"
        else
          raise 'There where something wrong in the initialization of the google client (Google::Apis::DriveV3::DriveService)'
        end
      end
    end
  end
end