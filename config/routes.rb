Rails.application.routes.draw do
  resources :heartbeat, only: [:index]

  # support login path
  get 'login', :to => 'index#login'

  resources :index, path: '/', only: [:index]

  # custom routes, as the MDS routes don't follow standard rails pattern
  # we need to add constraints, as the id may contain slashes

  # create media
  post 'media/:doi_id', :to => 'media#create', constraints: { :doi_id => /.+/ }

  # get media
  get 'media/:doi_id', :to => 'media#index', constraints: { :doi_id => /.+/ }

  # create metadata
  post 'metadata', :to => 'metadata#create'

  # get metadata
  get 'metadata/:doi_id', :to => 'metadata#index', constraints: { :doi_id => /.+/ }

  resources :dois, path: '/doi', constraints: { :id => /.+/ } do
    resources :metadata
    resources :media
  end

  root :to => 'index#index'

  # rescue routing errors
  match "*path", to: "index#routing_error", via: :all  
end
