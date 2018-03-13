require 'shrine'
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

class Shrine
  module Storage
    class GoogleDriveStorage
      attr_reader :prefix
      
      def initialize(prefix: nil, google_drive_client_secret_path: "config/gclient_secret.json", drive_public_folder_id: nil, google_drive_options: {})
        @prefix = prefix
        @google_drive_client_secret_path = google_drive_client_secret_path
        @drive_public_folder_id = drive_public_folder_id
        @google_drive_options = google_drive_options
      end

      def upload(io, id, shrine_metadata: {}, **_options)
        shrine_metadata = {
          name: "#{io.metadata['record_name']} #{id}",
          description: id,
          mime_type: io.metadata['mime_type'],
          parents: [@drive_public_folder_id]
        }

        s = StringIO.new
        s.write(io.read)
        s.rewind

        google_api_client.create_file(
          shrine_metadata,
          fields: 'id, name',
          upload_source: s,
          content_type: io.metadata['mime_type']
          )

        message = "Uploaded file #{id}"
      end

      def google_api_client
        if !@google_api_client || @google_api_client.authorization.expired?
          service = Google::Apis::DriveV3::DriveService.new
          service.client_options.application_name = ENV['APPLICATION_NAME']
          service.authorization = Google::Auth.get_application_default('https://www.googleapis.com/auth/drive')
          @google_api_client = service
        end
        @google_api_client
      end

      def url(id, **_options)
        begin
          metadata = google_api_client.get_file(
            google_api_client.list_files(q: "description contains '#{id}'").files[0].id,
            fields: 'webViewLink'
          )
          metadata.web_view_link
        rescue Exception => e
          p "URL ERR! #{e}"
        end
      end

    end
  end
end