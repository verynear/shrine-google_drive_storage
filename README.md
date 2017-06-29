# Shrine::Storage::GoogleDriveStorage

Provides [Google Drive Storage] for [Shrine].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shrine-google_drive_storage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shrine-google_drive_storage

## Google Drive Setup

Google Drive is a free service for file storage files. In order to use this storage you need a Google (or Google Apps) user which will own the files, and a Google API client.

1. Go to the [Google Developers console](https://console.developers.google.com/project) and create a new project, this option is on the top, next to the Google APIs logo.

2. Go to "API Manager > Library" in the section "Google Apps APIs" and enable "Drive API". If you are getting an "Access Not Configured" error while uploading files, this is due to this API not being enabled.

3. Go to "API Manager > Credentials" and click on "OAuth Client ID" before to select "Other" type you must specify `http://localhost` for application home page.

4. Now you will have a Client ID, Client Secret, and Redirect URL. So, download the client_secret_XXXXX.json file and rename it to client_secret.json.

5. Create a google drive folder in which the files will be uploaded; note the folder's ID.

## Usage

```rb
require "shrine/storage/google_drive_storage"

Shrine.storages = {
  cache: Shrine::Storage::GoogleDriveStorage.new(prefix: "cache"),
  store: Shrine::Storage::GoogleDriveStorage.new(prefix: "store"),
}
```

## Configuration

```rb
Shrine::Storage::GoogleDriveStorage.new(
  prefix: "store",
  google_drive_client_secret_path: "#{Rails.root}/config/client_secret.json",
  drive_public_folder_id: 'AAAARRRRGGGBBBFFFFadsasdX',
  google_drive_options: {
       	path: proc { |style| "#{id}_#{photo.original_filename}_#{style}" },
      },
)
```

The `:google_drive_client_secret_path` option

This is the path of the file downloaded from your Google Drive app settings by the authorization Rake task.

The `:drive_public_folder_id` option

This is the id of Google Drive folder that must be created in google drive and set public permissions on it

Example of the overridden `path/to/client_secret.json` file:
```json
{
  "client_id": "4444-1111.apps.googleusercontent.com",
  "client_secret": "1yErh1pR_7asdf8tqdYM2LcuL",
  "scope": "https://www.googleapis.com/auth/drive",
  "refresh_token": "1/_sVZIgY5thPetbWDTTTasdDID5Rkvq6UEfYshaDs5dIKoUAKgjE9f"
}
```
It is good practice to not include the credentials directly in the JSON file. Instead you can set them in environment variables and embed them with ERB. Alternatively, add the .json extention to your .gitignore file.

## Options

The `:google_drive_options` option

This is a hash containing any of the following options:
 - `:path` – block
 - `:default_image` - an image in Public folder that used for attachments if attachment is not present

The :path option should be a block which returns a path that the uploaded file should be saved to. The block yields the attachment style and is executed in the scope of the model instance.

## .env file
Create an `.env` file with these values:

```sh
# .env
APPLICATION_NAME = "..."
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "application-name.yaml")
```

The application name in the above cases is the project name you chose in the [Google Developers console](https://console.developers.google.com/project)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/verynear/shrine-google_drive_storage. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

[MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Shrine::GoogleDriveStorage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/verynear/shrine-google_drive_storage/blob/master/CODE_OF_CONDUCT.md).

[Google Drive Storage]: https://drive.google.com/drive/
[Shrine]: https://github.com/janko-m/shrine
