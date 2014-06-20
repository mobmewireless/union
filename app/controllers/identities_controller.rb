class IdentitiesController < ApplicationController
  skip_before_filter :require_authentication

  def new
    @identity = env['omniauth.identity']
  end
end
