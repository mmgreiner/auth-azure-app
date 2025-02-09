Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer, fields: [ :name, :email ]
  provider :entra_id, {
    client_id: ENV["AZURE_CLIENT_ID"],
    client_secret: ENV["AZURE_CLIENT_SECRET_VALUE"],
    tenant_id: ENV["AZURE_TENANT_ID"],
    scope: "openid email profile User.Read",
    response_type: "code",
    grant_type: "authorization_code"
  }
end

OmniAuth.config.logger = Rails.logger

# Ensure OmniAuth works in development without callback issues
OmniAuth.config.allowed_request_methods = [ :post, :get ]
OmniAuth.config.silence_get_warning = true
