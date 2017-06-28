require 'active_support/core_ext/hash/keys'
require 'active_support/inflector/methods'
require 'active_support/core_ext/object/blank'
require 'yaml'
require 'erb'

require 'shrine'
require 'google/apis/drive_v3'
require 'googleauth'
require 'shrine/google_drive/session'

require 'fileutils'

class Shrine
  module Storage
    class GoogleDriveStorage
      attr_reader :prefix

	  	def extended(base)
	      check_gem_is_installed
	      base.instance_eval do
	        @google_drive_client_secret_path = @options[:google_drive_client_secret_path]
	        @google_drive_options = @options[:google_drive_options] || { application_name: 'test-app' }
	        raise(ArgumentError, 'You must provide a valid google_drive_client_secret_path option') unless @google_drive_client_secret_path
	        raise(ArgumentError, 'You must set the public_folder_id option') unless @google_drive_options[:public_folder_id]
	        google_api_client # Force validations of credentials
	      end
	    end

	    def check_gem_is_installed
	      begin
	        require 'google-api-client'
	      rescue LoadError => e
	        e.message << '(You may need to install the google-api-client gem)'
	        raise e
	      end unless defined?(Google)
	    end
      

      def initialize(prefix: nil, google_drive_options: {})
        @prefix = prefix
        @google_drive_client_secret_path = @options[:google_drive_client_secret_path]
        @google_drive_options = @options[:google_drive_options]
      end

      def upload(io, id, shrine_metadata: {}, **_options)
        # uploads `io` to the location `id`
	      shrine_metadata = {
	        name: id,
	        description: 'shrine file on google drive',
	        mimeType: mime_type,
	        parents: folder_id
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
        @google_api_client ||= begin
          # Initialize the client & Google+ API
          ::Shrine::GoogleDrive::Session.from_config(
            @google_drive_client_secret_path,
            application_name: @google_drive_options[:application_name]
          )
        end
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
              client.delete_object(id)
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

      alias_method :object_name


      # Takes the file title/name and search it in a given folder
      # If it finds a file, return id of a file or nil
      # @param name [ String ]
      # @return [ String ] or NilClass
      def search_for_title(name)
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

    end
  end
end
