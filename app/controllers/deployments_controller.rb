class DeploymentsController < ApplicationController
  def deploy
    deployment = Deployment.find(params[:id])
    @job = deployment.deploy(current_user.email, admin: view_context.admin?)
  end

  def setup
    deployment = Deployment.find(params[:id])
    @job = deployment.setup(current_user.email, admin: view_context.admin?)
  end
end
