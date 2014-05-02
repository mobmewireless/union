class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :require_authentication

  private

  # Forces user to authenticate with Google OAuth before allowing access to interface elements.
  def require_authentication
    unless session[:authenticated]
      origin_string = URI.escape request.fullpath

      if Rails.env.production?
        redirect_to "/auth/google_oauth2?origin=#{origin_string}"
      else
        redirect_to "/auth/developer?origin=#{origin_string}"
      end
    end
  end

  # Requires user to be an admin to allow access to Admin interface.
  def require_admin
    unless view_context.admin?
      redirect_to root_url
    end
  end
end
