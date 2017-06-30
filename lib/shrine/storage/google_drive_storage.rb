require 'shrine'
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

class Shrine
  module Storage
    class GoogleDriveStorage
      attr_reader :prefix
      
      def initialize(prefix: nil, google_drive_client_secret_path: "#{Rails.root}/config/client_secret.json", drive_public_folder_id: nil, google_drive_options: {})
        @prefix = prefix
        @google_drive_client_secret_path = google_drive_client_secret_path
        @drive_public_folder_id = drive_public_folder_id
        @google_drive_options = google_drive_options
      end

      def upload(io, id, shrine_metadata: {}, **_options)
        # uploads `io` to the location `id`
	      shrine_metadata = {
	        name: id,
	        description: 'shrine file on google drive',
	        mime_type: mime_type,
	        parents: @drive_public_folder_id
	      }

	      google_api_client.create_file(
	        shrine_metadata,
	        fields: 'id, name',
	        upload_source: io.to_io,
	        content_type: shrine_metadata["mime_type"]
	        )
	   	  message = "Uploaded file #{file.name} with Id: #{file.id}"
      end

      def google_api_client
        if !@google_api_client || @google_api_client.authorization.expired?
          service = Google::Apis::DriveV3::DriveService.new
          service.client_options.application_name = ENV['APPLICATION_NAME']
          service.authorization = authorize
          @google_api_client = service
        end
        @google_api_client
      end

      alias_method :google_drive, :google_api_client

      def url(id, **_options)
        # URL to the remote file, accepts options for customizing the URL
        client = google_api_client
        metadata = client.get_file(
                    id,
                    fields: 'webViewLink'
                    )
        metadata.web_view_link
      end


      def download(id)
      	 client = google_api_client
         tempfile = Tempfile.new(["googledrive", File.extname(id)], binmode: true)
         client.get_file(
         			id,  
         			download_dest: tempfile)
         tempfile.tap(&:open)
       end

      def open(id)
        # returns the remote file as an IO-like object
          client = google_api_client
          io = client.get_file(
                    id,
                    download_dest: StringIO.new
                    )
          io.rewind
          io
      end


      def exists?(id)
        # checks if the file exists on the storage
        client = google_api_client
        client.get_file(id) do |_, err|
          if err
            if err.status_code == 404
              false
            else
              raise err
            end
          else
            true
          end
        end
      end

      def delete(id)
        # deletes the file from the storage
        google_api_client.delete_file(id) unless id.nil?

      rescue Google::Apis::ClientError => e
        # The object does not exist, Shrine expects us to be ok
        return true if e.status_code == 404

        raise e
      end

      def multi_delete(ids)
      	client = google_api_client
        ids.each_slice(100) do |ids|
          client.batch do |client|
            ids.each do |id|
              client.delete_file(id)
            end
          end
        end
      end

      def create_folder(name)
      	client = google_api_client
      	file_metadata = {
      		name: name,
      		mime_type: 'application/vnd.google-apps.folder'
      	}
      	file = client.create_file(file_metadata, fields: 'id, name')
      	message = "Created folder #{file.name} with folder id: #{file.id}"
      end

      def find_folder_id(name)
      	client = google_api_client
      	page_token = nil
      	begin
      	  response = client.list_files(q: "mimeType = 'application/vnd.google-apps.folder' and name contains '#{ name }'",
      	                                      spaces: 'drive',
      	                                      fields:'nextPageToken, files(id, name)',
      	                                      page_token: page_token)
      	  for file in response.files
      	    # Process change
      	    message = "Found folder: #{file.name} ID: #{file.id}"
      	  end
      	  page_token = response.next_page_token
      	end while !page_token.nil?
      end 

      def insert_in_folder(file_id, folder_id)
      	client = google_api_client
      	file = client.update_file(file_id,
      							  add_parents: folder_id,
      							  fields: 'id, name, parents')
      	message = "File #{file.name} with ID #{file.id} inserted into folder #{file.parents}"
      end

      def move_file(file_id, new_folder_id)
      	client = google_api_client
      	# Retrieve the existing parents to remove
      	file = client.get_file(file_id,
      	                       fields: 'parents')
      	previous_parents = file.parents.join(',')
      	# Move the file to the new folder
      	file = client.update_file(file_id,
      	                          add_parents: new_folder_id,
      	                          remove_parents: previous_parents,
      	                          fields: 'id, name, parents')
      	message = "File #{file.name} with ID #{file.id} moved to folder #{file.parents}"
      end

      def file_name(file_id)
        client = google_api_client
        metadata = client.get_file(
                    file_id,
                    fields: 'id, name'
                    )
        metadata.name
      end

      alias_method :object_name, :file_name


      # Takes the file title/name and search it in a given folder
      # If it finds a file, return id of a file or nil
      # @param name [ String ]
      # @return [ String ] or NilClass
      def search_for_file(name)
        raise 'You are trying to search a file with NO name' if name.nil? || name.empty?
        client = google_api_client
        result = client.list_files(page_size: 1,
                q: "name contains '#{ name }'",
                fields: 'files(id, name)'
                )
        if result.files.length > 0
          result.files[0].id
        else
          nil
        end
      end

      private

      # Ensure valid credentials, either by restoring from the saved credentials
      # files or intitiating an OAuth2 authorization. If authorization is required,
      # the user's default browser will be launched to approve the request.
      #
      # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
      def authorize
        scope = Google::Apis::DriveV3::AUTH_DRIVE
        client_secrets_path = @google_drive_client_secret_path
        credentials_path = ENV['CREDENTIALS_PATH']
        FileUtils.mkdir_p(File.dirname(credentials_path))

        client_id = Google::Auth::ClientId.from_file(client_secrets_path)
        token_store = Google::Auth::Stores::FileTokenStore.new(file: credentials_path)
        authorizer = Google::Auth::UserAuthorizer.new(
          client_id, scope, token_store)
        user_id = 'default'
        oob_uri = 'urn:ietf:wg:oauth:2.0:oob'
        credentials = authorizer.get_credentials(user_id)
        if credentials.nil?
          url = authorizer.get_authorization_url(
            base_url: oob_uri)
          $stderr.print("\n1. Open this page:\n%s\n\n" % url)
          $stderr.print('2. Enter the authorization code shown in the page: ')
          code = $stdin.gets.chomp
          credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: oob_uri, scope: scope)
        end
        credentials
      end



    end
  end
end
