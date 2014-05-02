class DeploymentsController < ApplicationController
  def deploy
    deployment = Deployment.find(params[:id])
    @job = deployment.deploy(session[:authenticated]['info']['email'].strip, admin: view_context.admin?)
  end

  def setup
    deployment = Deployment.find(params[:id])
    @job = deployment.setup(session[:authenticated]['info']['email'].strip, admin: view_context.admin?)
  end
end
