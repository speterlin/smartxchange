# config/initializers/searchkick.rb
require 'elasticsearch/transport/transport/http/faraday'

Searchkick.client = Elasticsearch::Client.new(
  url: ENV['ELASTICSEARCH_URL'],
  transport_class: Elasticsearch::Transport::Transport::HTTP::Faraday,
  transport_options: { request: { timeout: 10 } },
  adapter: :net_http,
  headers: { 'Content-Type' => 'application/json' },
  **{ skip_product_check: true }
)
