# config/initializers/searchkick.rb
Searchkick.client = Elasticsearch::Client.new(
  url: ENV['ELASTICSEARCH_URL'],
  retry_on_failure: true,
  transport_options: { request: { timeout: 10 } },
  adapter: :net_http,
  headers: { 'Content-Type' => 'application/json' },
  **{ transport_class: Elasticsearch::Transport::Transport::HTTP::Faraday, transport_options: { ssl: { verify: false } } },
  # This disables product check
  skip_product_check: true
)
