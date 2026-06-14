Rails.application.routes.draw do
  resources :categories do
    member { patch :reactivate }
  end
  resources :addresses do
    member { patch :reactivate }
  end
  resources :members do
    member { patch :reactivate }
  end
  resources :connections do
    collection { get :summary }
    member { patch :reactivate }
  end
  get  'invoice-candidates', to: 'invoice_candidates#index'
  post 'invoices/generate',  to: 'invoices#generate'
  resources :invoices

  get    'water-quality', to: 'water_quality#index'
  post   'water-quality', to: 'water_quality#create'
  delete 'water-quality', to: 'water_quality#destroy'

  namespace :auth do
    post :login, to: "/auth#login"
    post :refresh, to: "/auth#refresh"
  end

  scope :users do
    get :me, to: "users#me"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
