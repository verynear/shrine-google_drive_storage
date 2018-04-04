require 'dotenv/load'
require 'httparty'
require 'googleauth'

authorization = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open(ENV['GOOGLE_APPLICATION_CREDENTIALS']),
  scope: 'https://www.googleapis.com/auth/drive')

token = authorization.fetch_access_token!

p HTTParty.get('https://www.googleapis.com/drive/v3/files', 
  headers: {'Authorization' => "Bearer #{token["access_token"]}"})
