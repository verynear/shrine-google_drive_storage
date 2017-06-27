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

  context 'Manage an image' do

    it 'should upload an image' do
      VCR.use_cassette('upload_image') do
        dummy.document = File.new('spec/fixtures/image.png', 'rb')
        expect(dummy.document).to_not be_blank
        expect(dummy.document).to be_present
        expect(dummy.save).to be true
        expect(dummy.document.url).to be_present
        expect(dummy.document.url(:medium)).to be_present
        expect(dummy.document.url(:custom_thumb, width: 542)).to match(/=s542/)
      end
    end

    it 'should destroy an image' do
      VCR.use_cassette('remove_image') do
        dummy.save
        dummy.update_column(:document_file_name, 'image.png')
        dummy.update_column(:document_content_type, 'image/png')
        dummy.update_column(:document_fingerprint, 'c5591c5ae4d01cae00d27b1cfb95fb2e')
        dummy.destroy
        expect(dummy.document_file_name).to eq nil
        expect(dummy.document_content_type).to eq nil
        expect(dummy.document_fingerprint).to eq nil
      end
    end
  end

  context 'Errors' do
    it 'raise an error when the file already exist' do
      VCR.use_cassette('image_already_exists') do
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
        dummy = Dummy.new
        dummy.document = File.new('spec/fixtures/image.png', 'rb')
        expect{ dummy.save }.to raise_error(Shrine::Storage::GoogleDrive::FileExists)
      end
    end

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

  context 'Manage PDFs' do
    it 'should upload a pdf file' do
      VCR.use_cassette('upload_pdf') do
        dummy.document = File.new('spec/fixtures/document.pdf', 'rb')
        expect(dummy.document).to be_present
        expect(dummy.save).to be true
        expect(dummy.document.url).to be_present
      end
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
    it 'should upload a zip file' do
      VCR.use_cassette('upload_zip') do
        @dummy.document = File.new('spec/fixtures/document.zip', 'rb')
        expect(@dummy.document).to be_present
        expect(@dummy.save).to be true
        expect(@dummy.document.url).to be_present
        expect(@dummy.document.url(:custom_thumb, 100)).to eq('No picture')
      end
    end
  end
end