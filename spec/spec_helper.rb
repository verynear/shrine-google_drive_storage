$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'shrine-google_drive_storage'
Dir[File.join('./spec/support/**/*.rb')].each { |f| require f }
require 'rspec'
require 'pry'
require 'active_record'
require 'active_record/version'
require 'active_support'
require 'active_support/core_ext'
require 'pathname'
# require 'activerecord-import'

require 'webmock/rspec'

Pry.config.prompt = proc { |obj, nest_level, _| "ppc-gd> " }


#FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures")
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])
ActiveSupport::Deprecation.silenced = true

RSpec.configure do |config|
  config.include ModelReconstruction
end