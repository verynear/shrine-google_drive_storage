# Shrine::Storage::GoogleDriveStorage

Provides [Google Drive Storage] for [Shrine].

shout-outz to:  
https://github.com/verynear/shrine-google_drive_storage &&  
https://github.com/renchap/shrine-google_cloud_storage

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shrine-gdrive_storage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shrine-gdrive_storage

## Google Drive Setup

In order to use this storage you need a Google (or Google Apps) user which will own the files, and a Google API `client_secrets.json` file.

1. Go to the [Google Developers console](https://console.developers.google.com/project) and create a new project, this option is on the top, next to the Google APIs logo.

2. Go to "API Manager > Library" in the section "Google Apps APIs" and enable "Drive API". 

3. Go to "API Manager > Credentials" and create a new "Service Account Key".

4. Download the client_secret_XXXXX.json file and rename it to client_secret.json.

5. Create a google drive folder in which the files will be uploaded. 

_note:_ find the `drive_public_folder_id` by browsing to the folder via web at https://drive.google.com and get the id from the url, like such: `https://drive.google.com/drive/u/0/folders/AAAARRRRGGGBBBFFFFadsasdX`

## Environment variables

 (`cache: Shrine::Storage::GoogleDriveStorage.new(drive_public_folder_id: 'AAAARRRRGGGBBBFFFFadsasdX')`)  

use the [dotenv](https://rubygems.org/gems/dotenv) gem and add `require 'dotenv/load` to easily load values from your .env file  

Create an `.env` file with these values:

```sh
# .env
APPLICATION_NAME = "yourapp-12345"
GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/client_secret.json
GOOGLE_PUBLIC_FOLDER_ID=AAAARRRRGGGBBBFFFFadsasdX
```

__-or-__ set the environment variables however you like.

The application name in the above cases is the project name you chose in the [Google Developers console](https://console.developers.google.com/project)


## Usage

```rb
require "dotenv/load" #optional, load environment variables from .env file
require "shrine/storage/google_drive_storage"

Shrine.storages = {
  store: Shrine::Storage::GoogleDriveStorage.new,
}
```

you can use this for cache storage, too.

## Configuration

set the `drive_public_folder_id` here (instead of via environment variable) if you'd like

```rb
Shrine::Storage::GoogleDriveStorage.new(
  drive_public_folder_id: 'AAAARRRRGGGBBBFFFFadsasdX',
)
```

## Helpful info

If you are getting an "Access Not Configured" error while uploading files, this is due to this API not being enabled or, perhaps, your drive folder not having the correct permissions. 

Try sharing your folder (`drive_public_folder_id`) with the google service account user (see https:// or client_secret.json) something like: yourapp@yourapp-12345.iam.gserviceaccount.com. You might want to make your folder public.

or maybe use "Enable G Suite Domain-wide Delegation" via https://console.developers.google.com/iam-admin/serviceaccounts/project?project=yourapp-12345


## Miscellaneous

rtfm: http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/DriveV3

## Testing

a quick way to make sure your client_secret.json is working: 

    $ ruby test/gdrive_quickstart.rb

and then run this against the nifty shrinerb linters:

    $ rake test

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/edwardsharp/shrine-gdrive_storage. 

## License

[MIT License](http://opensource.org/licenses/MIT).


[Google Drive Storage]: https://drive.google.com/drive/
[Shrine]: https://github.com/janko-m/shrine
