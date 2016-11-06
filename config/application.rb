require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'yaml'
require 'pandorabots'
require 'omniauth'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# preload tokens in application.yml to local ENV
if Rails.env.development? || Rails.env.test?
  config = YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))
  config.merge! config.fetch(Rails.env, {})
  config.each do |key, value|
    ENV[key] = value.to_s unless value.kind_of? Hash
  end
end

module SmartXchange
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Europe/Madrid'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    #for using Faye as middleware and mounting onto /faye path
    # config.middleware.delete Rack::Lock
    # config.middleware.use FayeRails::Middleware, mount: '/faye', :timeout => 25
  end
end
