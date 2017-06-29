require_relative "test_helper"
require "shrine/storage/linter"
require "date"

describe Shrine::Storage::GoogleDriveStorage do
  def google_drive_storage(options = {})
      @options[:google_drive_client_secret_path] ||= 'spec/support/client_secret.json'
      @options[:google_drive_options] || { 
        application_name: 'test-app',
        public_folder_id: '0B-GFJI5FWVGyQXFKRzkydldoalk'
      }

    Shrine::Storage::GoogleDriveStorage.new(options)
  end


  before do
    @google_drive_storage = google_drive_storage
    shrine = Class.new(Shrine)
    shrine.storages = { google_drive_storage: @google_drive_storage }
    @uploader = shrine.new(:google_drive_storage)
  end


  it "passes the linter" do
    Shrine::Storage::Linter.new(google_drive_storage).call(-> { image })
  end

  it "passes the linter with prefix" do
    Shrine::Storage::Linter.new(google_drive_storage(prefix: 'pre')).call(-> { image })
  end


end
