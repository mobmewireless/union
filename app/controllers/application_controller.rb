class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :authenticate_user!

  private

  # Requires user to be an admin to allow access to Admin interface.
  def require_admin
    unless view_context.admin?
      redirect_to root_url
    end
  end
end
