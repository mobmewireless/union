class ApiController < ApplicationController
  respond_to :json

  skip_before_filter :require_authentication

  # Regular API routes are secured with an access token.
  before_filter :verify_access_token!, except: :webhook

  # Webhook calls are authenticated by verifying HMAC-SHA1 hash supplied by Trello.
  before_filter :verify_webhook_authenticity!, only: :webhook

  rescue_from Exceptions::UnionError do |e|
    render json: { code: e.code, error: e.message }
  end

  def deploy
    verify_deploy_params!

    job_ids = fetch_deployments.map do |deployment|
      deployment.deploy(APP_CONFIG['access_tokens'][params['access_token']], admin: true).id
    end

    respond_with job_ids: job_ids
  end

  def webhook
    Union::Trello::WebhookProcessor.process(request.body.read)

    render json: { status: 'success' }
  end

  private

  # Raises Exceptions::ApiParameterMissing when parameters supplied are insufficient for deployment(s) to be identified.
  def verify_deploy_params!
    if params[:project_id]
      unless params[:project_name]
        raise Exceptions::ApiParametersMissing, "Missing required parameter 'project_name'"
      end

      return
    elsif params[:deployment_id]
      unless params[:deployment_name]
        raise Exceptions::ApiParametersMissing, "Missing required parameter 'deployment_name'"
      end

      return
    end

    raise Exceptions::ApiParametersMissing, "Deployment requires 'project_id' and 'project_name', or 'deployment_id' and 'deployment_name'"
  end

  # Raises Exceptions::ApiKeyInvalid unless the supplied access token is valid.
  def verify_access_token!
    unless APP_CONFIG['access_tokens'][params[:access_token]]
      raise Exceptions::ApiKeyInvalid, 'Invalid access token'
    end
  end

  # Fetches deployments, depending on whether deploy action was request on a single deployment or a project.
  #
  # @return [Array] deployments to be deployed.
  def fetch_deployments
    if params[:project_id]
      project = begin
        Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
        raise Exceptions::ApiParameterInvalid, "Could not find project with ID #{params[:project_id]}"
      end

      unless project.project_name == params[:project_name]
        raise Exceptions::ApiParameterInvalid, "Supplied project_name (#{params[:project_name]}) does not match found deployment's name (#{project.project_name})"
      end

      project.deployments.all
    else
      deployment = begin
        Deployment.find(params[:deployment_id])
      rescue ActiveRecord::RecordNotFound
        raise Exceptions::ApiParameterInvalid, "Could not find deployment with ID #{params[:deployment_id]}"
      end

      unless deployment.deployment_name == params[:deployment_name]
        raise Exceptions::ApiParameterInvalid, "Supplied deployment_name (#{params[:deployment_name]}) does not match found deployment's name (#{deployment.deployment_name})"
      end

      [deployment]
    end
  end

  def verify_webhook_authenticity!
    if request.head?
      render nothing: true, status: 200, content_type: 'text/html'
      return false
    end

    digest_sha1 = OpenSSL::Digest::SHA1.new
    hash = OpenSSL::HMAC.digest digest_sha1, APP_CONFIG[:trello][:api_secret], request.body.read + APP_CONFIG[:trello][:webhook_callback_url]
    base64_hash = Base64.strict_encode64 hash

    unless base64_hash == request.headers['x-trello-webhook']
      message = 'HMAC-SHA1 hash verification failed. This request has been ignored.'
      logger.warn "#{message} Expected/Received Hash is #{base64_hash}/#{request.headers['x-trello-webhook']}"
      raise Exceptions::WebhookAuthenticationFailed, message
    end
  end
end
