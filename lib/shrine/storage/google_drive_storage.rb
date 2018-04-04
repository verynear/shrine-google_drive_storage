require 'shrine'
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'down/chunked_io'
require 'fileutils'

class Shrine
  module Storage
    class GoogleDriveStorage
      
      def initialize(drive_public_folder_id: nil, google_drive_options: {})
        @drive_public_folder_id = drive_public_folder_id || ENV["GOOGLE_PUBLIC_FOLDER_ID"]
      end

      def upload(io, id, shrine_metadata: {}, **_options)
        mime_type = io.metadata['mime_type'] rescue 'image/jpeg'

        s = StringIO.new
        s.write(io.read)
        s.rewind
        google_api_client.create_file(
          { name: id,
            mime_type: mime_type,
            parents: [@drive_public_folder_id]
          },
          fields: 'id, name',
          upload_source: s,
          content_type: shrine_metadata['mime_type']
        )

        message = "Uploaded file #{id}"
      end

      def exists?(id)
        get_drive_file_id(id)
      end

      def open(id)
        sio = StringIO.new
        google_api_client.get_file(
          get_drive_file_id(id),
          download_dest: sio
        )
        sio.rewind
        sio
      end

      def url(id, **_options)
        begin
          metadata = google_api_client.get_file(
            get_drive_file_id(id),
            fields: 'webViewLink'
          )
          metadata.web_view_link
        rescue Exception => e
          # p "URL ERR! #{e}"
          #TODO: something meaningful?
        end
      end

      def delete(id)
        google_api_client.delete_file(get_drive_file_id(id)) rescue nil        
      end

      private

      def get_drive_file_id(id)
        google_api_client.list_files(q: "name contains '#{id}'").files[0].id rescue nil
      end

      def google_api_client
        if !@google_api_client || @google_api_client.authorization.expired?
          service = Google::Apis::DriveV3::DriveService.new
          service.client_options.application_name = ENV['APPLICATION_NAME']
          service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
            json_key_io: File.open(ENV['GOOGLE_APPLICATION_CREDENTIALS']),
            scope: Google::Apis::DriveV3::AUTH_DRIVE)
          @google_api_client = service
        end
        @google_api_client
      end

    end
  end
end