require 'spec_helper'

describe 'Shrine::Storage::GoogleDrive' do
  let(:dummy) do
    rebuild_model(
      storage: :google_drive,
      google_drive_client_secret_path: 'spec/support/client_secret.json',
      styles: { medium: '300x300' },
      google_drive_options: {
        application_name: 'test-app',
        public_folder_id: '0B-GFJI5FWVGyQXFKRzkydldoalk',
        path: proc { |style| "#{style}_#{id}_#{document.original_filename}" }
      }
    )
    Dummy.new
  end


  context 'Errors' do

    it 'raise an error when is not passed the google_drive_client_secret_path option' do
      rebuild_model(
        storage: :google_drive,
        google_drive_client_secret_path: nil
      )
      expect{ Dummy.new.save }.to raise_error(ArgumentError, 'You must provide a valid google_drive_client_secret_path option')
    end

    it 'raise an error when is passed a invalid google_drive_client_secret_path option' do
      rebuild_model(
        storage: :google_drive,
        google_drive_client_secret_path: 'path/to/nowhere.json',
        google_drive_options: {
          application_name: 'test-app',
          public_folder_id: 'folder-id',
        }
      )
      expect{ Dummy.new.save }.to raise_error(ArgumentError, 'Missing required client identifier.')
    end

    it 'raise an error when is not passed the application_name option' do
      rebuild_model(
        storage: :google_drive,
        google_drive_client_secret_path: 'spec/support/client_secret.json',
        google_drive_options: {
          public_folder_id: 'folder-id',
          application_name: nil
        }
      )
      expect{ Dummy.new.save }.to raise_error(ArgumentError, 'You must specify the application_name option')
    end

    it 'raise an error when there is not passed the public_folder_id option' do
      rebuild_model(
        storage: :google_drive,
        google_drive_client_secret_path: 'spec/support/client_secret.json',
        google_drive_options: {
          application_name: 'test-app',
          public_folder_id: nil,
        }
      )
      expect{ Dummy.new.save }.to raise_error(ArgumentError, 'You must set the public_folder_id option')
    end
  end

  

  context 'Manage ZIP files' do
    before :each do
      rebuild_model(
      storage: :google_drive,
      google_drive_client_secret_path: 'spec/support/client_secret.json',
      google_drive_options: {
        application_name: 'test-app',
        public_folder_id: '0B-GFJI5FWVGyQXFKRzkydldoalk',
        path: proc { |style| "#{style}_#{id}_#{document.original_filename}" }
      }
    )
    @dummy = Dummy.new
    end
    
  end
end