# config/initializers/searchkick.rb
Searchkick.client = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'], retry_on_failure: true)
