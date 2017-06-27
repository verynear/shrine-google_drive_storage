# Author: Mateusz Czerwinski <mtczerwinski@gmail.com>
# The license of this source is "New BSD Licence"
require 'json'
require 'googleauth'
require 'fileutils'

module Shrine
  module GoogleDrive
    # @api private
    class Config
      FIELDS = %w(client_id client_secret scope refresh_token).freeze
      attr_accessor(*FIELDS)

      def initialize(config_path)
        @config_path = config_path
        if ::File.exist?(config_path)
          JSON.parse(::File.read(config_path)).each do |key, value|
            instance_variable_set("@#{key}", value) if FIELDS.include?(key)
          end
          if !client_id
            auth_client = Google::Auth::ClientId.from_file(config_path)
            @client_id = auth_client.id
            @client_secret = auth_client.secret
          end
        end
      end

      def save
        ::File.open(@config_path, 'w', 0600) { |f| f.write(to_json) }
      end

      private

      def to_json
        hash = {}
        FIELDS.each do |field|
          value = __send__(field)
          hash[field] = value if value
        end
        JSON.pretty_generate(hash)
      end
    end
  end
end