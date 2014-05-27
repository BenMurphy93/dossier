require 'rails/all'
require 'dummy/application'
require 'active_model'
require 'simplecov'
require 'coveralls'

# not sure why I need to do this now, its after I added dummy-application
ApplicationController.helper Dossier::ApplicationHelper
SiteController.helper Dossier::ApplicationHelper

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start
Coveralls.wear!('rails')

require "rails/test_help"
require 'rspec/rails'
require 'pry'
require 'genspec'
require 'capybara/rspec'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

DB_CONFIG = [:mysql2, :sqlite3].reduce({}) do |config, adapter_name|
  config.tap do |hash|
    path = "spec/fixtures/db/#{adapter_name}.yml"
    hash[adapter_name] = YAML.load_file(path).symbolize_keys if File.exist?(path)
  end
end.freeze

RSpec.configure do |config|
  config.mock_with :rspec

  config.before :suite do
    DB_CONFIG.keys.each do |adapter|
      Dossier::Factory.send("#{adapter}_create_employees")
      Dossier::Factory.send("#{adapter}_seed_employees")
    end
  end

  config.after :each do
    Dossier.instance_variable_set(:@configuration, nil)
  end

  config.order = :random
end
