CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
    :region                 => ENV['AWS_REGION'] # 'us-east-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['AWS_BUCKET'] # 'smartxchange'  # required
  config.fog_public     = false # true     # optional, defaults to true
  config.fog_attributes = { cache_control: "public, max-age=86400" } # {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end



MiniMagick.configure do |config|
  config.cli = :imagemagick
end
