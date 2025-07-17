# config/initializers/searchkick.rb
Searchkick.client = Elasticsearch::Client.new(
  url: ENV['ELASTICSEARCH_URL'],
  transport_options: { request: { timeout: 10 } },
  adapter: :net_http,
  transport_class: Elasticsearch::Transport::Transport::HTTP::Faraday,
  headers: { 'Content-Type' => 'application/json' }
)

# Disable product check manually
Searchkick.client.transport.connections.each do |conn|
  conn.instance_variable_set(:@verified, true)
end
