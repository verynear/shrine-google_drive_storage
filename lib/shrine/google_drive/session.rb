# Author: Hiroshi Ichikawa <http://gimite.net/>
# The license of this source is "New BSD Licence"
require 'google/apis/drive_v3'
require 'googleauth'
require 'shrine/google_drive/config'
require 'fileutils'

module Shrine
  module GoogleDrive
    # A session for Google Drive operations.
    #
    # Use from_credentials, from_access_token, from_service_account_key or from_config
    # class method to construct a Shrine::GoogleDrive::Session object.
    class Session

      DEFAULT_SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

      # Returns Google::Apis::DriveV3::DriveService constructed from a config JSON file at +config+.
      #
      # +config+ is the path to the config file.
      #
      # This will prompt the credential via command line for the first time and save it to
      # +config+ for later usages.
      #
      # See https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md for a usage example.
      #
      # You can also provide a config object that must respond to:
      #   client_id
      #   client_secret
      #   refesh_token
      #   refresh_token=
      #   scope
      #   scope=
      #   save
      class << self
        def from_config(config_path, options = {})
          validate_options(options)
          config = get_cofiguration(config_path, options)
          credentials = Google::Auth::UserRefreshCredentials.new(
            client_id: config.client_id,
            client_secret: config.client_secret,
            scope: config.scope,
            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
          )
          if config.refresh_token
            credentials.refresh_token = config.refresh_token
            credentials.fetch_access_token!
          else
            $stderr.print("\n1. Open this page:\n%s\n\n" % credentials.authorization_uri)
            $stderr.print('2. Enter the authorization code shown in the page: ')
            credentials.code = $stdin.gets.chomp
            credentials.fetch_access_token!
            config.refresh_token = credentials.refresh_token
          end
          config.save
          init_drive_service(options[:application_name], credentials)
        end

        # @param config_path [ String ]
        # @param options [ Hash ]
        # @return [ Shrine::GoogleDrive::Config ]
        def get_cofiguration(config_path, options)
          if config_path.is_a?(String)
            config = Shrine::GoogleDrive::Config.new(config_path)
          else
            raise(ArgumentError, 'You must set a valid config_path path')
          end
          config.scope ||= DEFAULT_SCOPE
          config_from_options(config, options)
        end

        # @param options [ Hash ]
        # @param  config [ Shrine::GoogleDrive::Config ]
        # @return [ Shrine::GoogleDrive::Config ]
        def config_from_options(config, options)
          if options[:client_id] && options[:client_secret]
            config.client_id = options[:client_id]
            config.client_secret = options[:client_secret]
          end
          config
        end

        # @param options [ Hash ]
        def validate_options(options)
          raise(ArgumentError, 'You must specify the application_name option') unless options[:application_name]
          raise(ArgumentError, 'client_id and client_secret must be both specified or both omitted') if invalid_client_options?(options)
        end

        # @param options [ Hash ]
        # @return [ Boolean ]
        def invalid_client_options?(options)
          (options[:client_id] && !options[:client_secret]) || (!options[:client_id] && options[:client_secret])
        end

        # @param application_name [ String ]
        # @param credentials [ Google::Auth::UserRefreshCredentials ]
        # @return [ Google::Apis::DriveV3::DriveService ]
        def init_drive_service(application_name, credentials)
          # Initialize the API
          client = Google::Apis::DriveV3::DriveService.new
          client.client_options.application_name = application_name
          client.authorization = credentials
          client
        end
      end
    end
  end
end