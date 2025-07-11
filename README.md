# smartXchange

A Ruby on Rails application to allow users to find each other for the purpose of practicing languages and sharing language learning material. Featured in prominent business school career newsletter with users over the world. Constantly adding new features, open to suggestions. Created in 2016, updated in 2025. See it [Live](http://smartexchange.herokuapp.com). <!--- Not using ENV['HTTP_HOST'] because upload with git not heroku therefore localhost:300 would be pushed not the public url -->

## Features and Gems

* Ruby, Rails (3.4.3, 7.2.2.1 update from 2.5, 5.2 in 2016), using Puma server locally, Redis in production<!--Ruby 2.5, Rails 5.2-->

* Turbolinks for faster web navigation

* Bootstrap template and Sass for styling

* BCrypt for encryption

* Carrierwave, Mini_magick, Fog, File_validators, and Remotipart for uploading images and materials

* AWS for storing images and materials

* Heroku for hosting (heroku-24 stack update from heroku-19 stack in 2016)

* Braintree and Gon for payments

* Prototyping chatbot technology through chatbots.io and modified Pandorabots_api gem

* Basic Linkedin integration with Omniauth-oauth2

* Geocoder for location

* Recaptcha to protect against spam and abuse

* Delayed_job_active_record and Sendgrid-ruby for sending and tracking emails

* Opengraph_parser for displaying link images and Rails_autolink for recognizing links in text

* Searchkick for searching users<!---  and posts -->

* Acts-as-taggable-on for tagging posts and comments

* Jquery_textcomplete for text autocomplete

* Newrelic_rpm for monitoring and analysis

* Database using Sqlite3 for development and Postgres in production

## Other Information

* Security test results from Acunetix, Beyond Security, and Detectify show medium to low vulnerability

* Some issues when running on internet explorer

* Services (language learning, materials, matching, networking, trustworthy interactions)

## Contributing

  1. Fork it
  1. Create your feature branch (`git checkout -b my-new-feature`)
  1. Commit your changes (`git commit -am 'Add some feature'`)
  1. Push to the branch (`git push origin my-new-feature`)
  1. Create new Pull Request

Bug reports and pull requests are welcome on GitHub at https://github.com/speterlin/smartxchange. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
