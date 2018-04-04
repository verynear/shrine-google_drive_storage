require 'dotenv/load'
require 'google/apis/drive_v3'
require 'googleauth'

service = Google::Apis::DriveV3::DriveService.new
service.client_options.application_name = ENV['APPLICATION_NAME']

service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open(ENV['GOOGLE_APPLICATION_CREDENTIALS']),
  scope: Google::Apis::DriveV3::AUTH_DRIVE)


response = service.list_files
puts 'Files:'
puts 'No files found' if response.files.empty?
response.files.each do |file|
  puts "#{file.name} (#{file.id})"
end


s = StringIO.new
s.write(open('test/fixtures/image.jpg'))
s.rewind

PUBLIC_FOLDER_ID = '1pDCgqxi7pLM4I_o6byLdc9EF4bsblEis'
p "gonna upload a file:"
service.create_file(
  { name: 'a test image',
    description: 'some description',
    parents: [PUBLIC_FOLDER_ID]
  },
  fields: 'id, name',
  upload_source: s,
  content_type: 'image/jpg'
  )
