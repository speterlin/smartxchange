Rails.application.config.middleware.use OmniAuth::Builder do
  # only have these at the moment (need partnership to get access to more with linkedin ): 'r_basicprofile r_emailaddress', by default, picturl-url is small image so including other option only which has bigger picture, positions and specialties showing up as null for e
  provider :linkedin, ENV['LINKEDIN_API_KEY'], ENV['LINKEDIN_SECRET_KEY'],
            scope: 'r_liteprofile r_emailaddress',
            fields: ['id', 'firstName', 'lastName', 'profilePicture', 'emailAddress'] # 'email-address', 'first-name', 'last-name', 'headline', 'location', 'industry', 'summary', 'specialties', 'positions', 'picture-urls::(original)', 'public-profile-url', 'picture-url', 'picture_url',  #, :scope => 'r_liteprofile'
end
# puts "OmniAuth LinkedIn strategy loaded"
# chatgpt: Starting from OmniAuth 2.0, GET requests to /auth/:provider are disabled by default for security. It now expects POST requests to /auth/:provider.
if Rails.env.development? || Rails.env.test?
  OmniAuth.config.allowed_request_methods = [:get, :post]
  OmniAuth.config.silence_get_warning = true # optional, suppress warning
end
