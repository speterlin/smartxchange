source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
#will need postgres for heroku deployment
#gem 'pg', '~> 0.18.4' error installing will keep out for now
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
#bootstrap
gem 'bootstrap-sass'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# don't think I use sdoc
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc


#for generating password encryption, also has_secure_password
gem 'bcrypt'

#for uploading images and attachments, need mini_magick
gem 'carrierwave', '~> 1.0'
gem 'mini_magick'
gem 'fog-aws'
# file size limit
gem 'file_validators'

#for generating fake value
gem 'faker'

#for pagination
gem 'will_paginate'
gem 'bootstrap-will_paginate'

# new gems for chat
gem 'puma', '~> 3.0'

# for chatbot,  modified repo
gem 'pandorabots_api', :git => "https://github.com/speterlin/pb-ruby.git"

# for linkedin integration
gem 'omniauth-oauth2', '~> 1.3.1' # fix for redirect_uri issue after logging in with linkedin, would like to get rid of it refactor
gem 'omniauth-linkedin-oauth2' # could have used regular omniauth works the same

# for recognizing text as links for ruby
gem 'rails_autolink'

# for using location in algorithm
gem 'geocoder'

# payments
gem 'braintree', '~> 2.33.1'
gem 'gon', '~> 5.1.2'

# recaptcha
gem 'recaptcha', require: 'recaptcha/rails'

# for background jobs
gem 'delayed_job_active_record'

# for remote file uploads
gem 'remotipart', '~> 1.2'

# for tracking emails
gem 'sendgrid-ruby'

# for finding images of links on boards pages
gem 'opengraph_parser'

# for searching users (and their linkedin, materials)
gem 'searchkick'
# for tracking searches
# gem 'searchjoy'

# for tagging posts
gem 'acts-as-taggable-on', '~> 4.0'

# for boards and header autocomplete
gem 'jquery_textcomplete'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# For use in debugging and in user_mailer.rb#set_name_and_title_and_unsubscribe_and_header
gem 'binding_of_caller'

# Access an IRB console on exception pages or by using <%= console %> in views
gem 'web-console', '~> 2.0', group: :development

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'annotate'
  gem 'better_errors'

  gem 'pry-rails'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
end

group :production do
  ruby "2.3.3"
  gem 'pg'
  gem 'rails_12factor'
  # for action cable to work
  gem 'redis', '~> 3.0'

end
