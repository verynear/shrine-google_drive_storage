require_relative "test_helper"
require "shrine/storage/linter"
require "date"

describe Shrine::Storage::GoogleDriveStorage do
  def google_drive_storage(options = {})
    Shrine::Storage::GoogleDriveStorage.new({ 
        drive_public_folder_id: '17Vz1HBcJjasJmo8sCt8vKmda92Ayk3cw'
      })
  end

  before do
    @google_drive_storage = google_drive_storage
    shrine = Class.new(Shrine)
    shrine.storages = { google_drive_storage: @google_drive_storage }
    # @uploader = shrine.new(:google_drive_storage)
  end

  # after do
  #   @google_drive_storage.clear!
  # end

  it "passes the linter" do
    Shrine::Storage::Linter.new(google_drive_storage).call(-> { image })
  end

end
