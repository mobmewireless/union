Union::Application.routes.draw do
  get 'boards/show'

  # Projects section - the heart of this 'project'. :)
  resources :projects, except: %w(new edit) do
    post 'deploy', on: :member
    post 'setup', on: :member
    post 'refresh', on: :member
  end

  # Delayed Jobs
  post 'delayed_jobs/clear' => 'delayed_jobs#clear', as: :delayed_jobs_clear

  # Deployments
  post 'deployments/:id/deploy' => 'deployments#deploy', as: :deploy_deployment
  post 'deployments/:id/setup' => 'deployments#setup', as: :setup_deployment

  # Server list
  resources :servers, only: %w(index show destroy create update) do
    get 'metrics', on: :member
  end

  # Administration section
  resources :admin, only: %w(index) do
    post 'refresh_projects', on: :collection
    post 'add_projects', on: :collection
    post 'refresh_boards', on: :collection
  end

  resources :jobs, only: %w(index show) do
    get 'logs', on: :member
  end

  # Change management.
  scope 'metrics' do
    get ':board_id' => 'metrics#board', as: 'metrics_board'
    get ':board_id/burndown' => 'metrics#burndown', defaults: { format: 'json' }, as: 'metrics_burndown'
  end

  # Trello Boards
  resources :boards, only: %w(show update destroy) do
    post 'subscribe', on: :member
    post 'unsubscribe', on: :member
  end

  # API
  scope 'api' do
    get 'deploy' => 'api#deploy', defaults: { format: 'json' }
    match 'webhook' => 'api#webhook', via: [:get, :post]
  end

  # Auth routes
  match 'auth/:provider/callback' => 'sessions#create', via: [:get, :post]
  match 'auth/failure' => 'sessions#failure', via: [:get, :post]
  get 'logout' => 'sessions#destroy', as: 'logout'

  # Root '/' leads to the project index
  root to: 'projects#index'
end
