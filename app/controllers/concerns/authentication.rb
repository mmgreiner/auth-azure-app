module Authentication
  # TODO
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      session[:user_id]
    end

    def require_authentication
      authenticated? || request_authentication
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to sessions_new_path
    end
end
