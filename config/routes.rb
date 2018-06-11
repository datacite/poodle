Rails.application.routes.draw do
  resources :heartbeat, only: [:index]

  # support login path
  get 'login', :to => 'index#login'

  resources :index, path: '/', only: [:index]

  resources :dois, path: '/doi', only: [:show, :index, :update], constraints: { :id => /.+/ }
  resources :metadata, only: [:show, :create, :delete], constraints: { :id => /.+/ }

  # custom routes, as the MDS routes don't follow standard rails pattern
  # we need to add constraints, as the id may contain slashes

  # # create identifier
  # put 'id/:id', :to => 'works#create', constraints: { :id => /.+/ }

  # # mint identifier
  # post 'shoulder/:id', :to => 'works#mint', constraints: { :id => /.+/ }

  # # update identifier
  # post 'id/:id', :to => 'works#update', constraints: { :id => /.+/ }

  # # delete identifier
  # delete 'id/:id', :to => 'works#delete', constraints: { :id => /.+/ }

  root :to => 'index#index'

  # rescue routing errors
  match "*path", to: "index#routing_error", via: :all  
end
