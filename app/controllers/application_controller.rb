class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :authenticate_user!
  # before_filter :require_authentication

  private

  # Forces user to authenticate with Google OAuth before allowing access to interface elements.
  def require_authentication
    unless session[:authenticated]
      redirect_to '/login'
    end
  end

  # Requires user to be an admin to allow access to Admin interface.
  def require_admin
    unless view_context.admin?
      redirect_to root_url
    end
  end
end
