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

  resources :exams, only: [:index]
  
  resources :students

  
  resources :standards, only: [] do
    member do
      get 'optional_subjects'
    end
  end
  
  
  resources :jkci_classes do
    member do
      get 'get_exam_info'
      get 'toggle_class_sms'
      get 'toggle_exam_sms'
      get 'assign_students'
      get 'students'
      post 'manage_students'
      #delete 'remove_students'
    end
    resources :exams, except: [:index] do
      member do
        get 'get_catlogs'
        get 'verify_exam'
        get 'exam_conducted'
        get 'get_exam_info'
        get 'get_descendants'
        post 'add_absunt_students'
        post 'upload_paper'
        post 'add_exam_results'
        post 'verify_exam_result'
        post 'verify_exam_absenty'
        post 'publish_exam_result'
      end
      resources :exams, only: [:create]
    end
    delete "students/:student_id" => "jkci_classes#remove_student_from_class"
  end

  get '/organisation_cources' => "organisations#organisation_cources"
  get '/remaining_cources' => "organisations#remaining_cources"
  get '/organisations/get_sub_organisations' => "organisations#sub_organisations_list"
  get '/organisations/add_standards' => "organisations#add_standards"
  get '/organisations/get_clarks' => "organisations#get_clarks"
  get '/organisations/users/:user_id/get_roles' => "organisations#get_clark_roles"
  get "/organisations/users/:user_id/toggleEnable" => "organisations#toggle_enable_users"
  get "/organisations/users/:user_id/get_email" => "organisations#get_user_email"
  get "/organisations/get_standards" => "organisations#get_organisation_standards"
  post "/organisations/users/:user_id/update_clark_password" => "organisations#update_clark_password"
  post "/organisations/users/:user_id/update_roles" => "organisations#update_clark_roles"
  post "/organisations/users/create_organisation_clark" => "organisations#create_organisation_clark"
  post "/organisations/sub_organisation/launch_organisation" => "organisations#launch_sub_organisation"
  delete "/organisations/clarks/:user_id" => "organisations#delete_clark"
  delete "/organisations/sub_organisations/:sub_organisation_id" => "organisations#pull_back_sub_organisations"

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
