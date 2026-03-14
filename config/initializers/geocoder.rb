Geocoder.configure(
  lookup: :nominatim,
  timeout: 5,
  units: :mi,
  cache: Rails.cache,
  http_headers: { "User-Agent" => "rails-app" }
)
