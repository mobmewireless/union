# Manages creation and destruction of user sessions.
class SessionsController < ApplicationController
  # Omniauth's development login page doesn't supply an authenticity token on the form, so let's skip checking for it.
  skip_before_filter :verify_authenticity_token if Rails.env.development?

  # This is the where authentication occurs, after all.
  # skip_before_filter :require_authentication
  skip_before_filter :authenticate_user!

  def new
    redirect_to request.env['omniauth.origin'] || '/' if session[:authenticated]
  end

  # Create an authorized session if the e-mail received from Google Authentication callback is an approved email address.
  def create
    if auth_hash['info']['email'].ends_with? "@#{APP_CONFIG[:allowed_email_host]}"
      session[:authenticated] = auth_hash
      redirect_to request.env['omniauth.origin'] || '/'
    else
      @unauthenticated_email_address = auth_hash['info']['email']
      @reason = :unauthenticated_email_address
      render :action => 'failure', :layout => 'application_unauthenticated'
    end
  end

  # Authentication failure management.
  def failure
    require 'base64'

    case params[:message]
    when 'invalid_credentials'
      @reason = :invalid_credentials
    else
      @reason = params.inspect
    end

    render :layout => 'application_unauthenticated'
  end

  # Logout.
  def destroy
    # session[:authenticated] = false
    # render :layout => 'application_unauthenticated'
  end

protected

  # Returns omniauth's post-authorization details hash.
  def auth_hash
    request.env['omniauth.auth']
  end

  def organization_of(organization_url)
    data = JSON.parse(open(organization_url).read)
    data.map { |x| x['login'] }
  end
end