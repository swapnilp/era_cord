Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "
  devise_for :users,
  controllers: {
    invitations:   'users/invitations',
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    unlocks:       'users/unlocks',
  },
  skip: [:confirmations, :registrations]
  
  # as :user do
  #   put 'users/change-password', to: 'users/registrations#update', as: 'user_password_change'
  # end

  devise_scope :user do
    root to: "users/sessions#new"
  end
  resources :exams

  get '/organisation_cources' => "organisations#organisation_cources"
  get '/remaining_cources' => "organisations#remaining_cources"
  get '/organisations/add_standards' => "organisations#add_standards"
  get '/organisations/get_clarks' => "organisations#get_clarks"
  get '/organisations/users/:user_id/get_roles' => "organisations#get_clark_roles"
  get "/organisations/users/:user_id/toggleEnable" => "organisations#toggle_enable_users"
  post "/organisations/users/:user_id/update_roles" => "organisations#update_clark_roles"

  
  get 'index' => "home#index"
  #root 'home#index'
  
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
