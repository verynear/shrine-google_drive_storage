require 'active_support/core_ext/module'
module Shrine
  module GoogleDrive
    class Railtie < Rails::Railtie
      rake_tasks do
        load "shrine/google_drive/tasks.rake"
      end
    end
  end
end