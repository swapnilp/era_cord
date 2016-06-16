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
    registrations: 'users/registrations',
  },
  skip: [:confirmations]

  resources :register_organisations do
    member do 
      get :sms_confirmation
      post :verify_confirmation
    end
  end

  resources :sms_sent, only: [:index]

  resources :parents_meetings, only: [:index, :new, :create, :show] do
    collection do 
      get :get_class_students
    end
  end
  
  resources :questions, only: [:index, :show] do
    collection do 
      get :filter_info
    end
  end
  
  
  # as :user do
  #   put 'users/change-password', to: 'users/registrations#update', as: 'user_password_change'
  # end


  as :user do
    #get 'users/password/edit', to: "users/passwords#edit", as: 'edit_user_password'
    post 'users/reset_password', to: "users/passwords#create", as: 'user_password_reset'
   # put 'users/update_password', to: "users/passwords#update", as: 'password'
  end

  #devise_scope :user do
  #  root to: "users/sessions#new"
  #end

  resources :exams, only: [:index] do 
    collection do 
      get 'calender_index'
      get 'get_filter_data'
    end
  end

  resources :off_classes, only: [:index] do 
    collection do 
      get 'calender_index'
    end
  end
  
  resources :students, except: [:update] do
    member do
      get 'download_report'
      get 'get_graph_data'
      get 'get_fee_info'
      get 'get_payments_info'
      post 'paid_student_fee'
      post 'update'
      post 'toggle_sms'
    end
    collection do 
      get 'get_filter_values'
    end
  end

  resources :standards, only: [] do
    member do
      get 'optional_subjects'
    end
  end

  resources :student_fees, only: [:index] do
    member do
      get 'print_receipt'
    end
    
    collection do
      get "filter_data"
      get "graph_data"
      get 'print_account'
      get "download_excel"
    end
  end

  get "get_unassigned_classes" => "jkci_classes#get_unassigned_classes"
  get "sub_organisation/:sub_organisation_id/class/:jkci_class_id/get_report" => "jkci_classes#sub_organisation_class_report", as: "sub_organisation_class_report"
  get "/class/:id/download_class_catlog" => "jkci_classes#download_class_catlog", as: "download_class_catlog"
  get "/class/:id/download_class_student_list" => "jkci_classes#download_class_student_list", as: "download_class_student_list"
  get "/class/:id/download_class_syllabus" => "jkci_classes#download_class_syllabus", as: "download_class_syllabus"
  get "/classes/:id/download_excel" => "jkci_classes#download_excel"
  
  resources :jkci_classes do
    member do
      get 'presenty_catlog'
      get 'download_presenty_catlog'
      get 'get_exam_info'
      get 'get_dtp_info'
      get 'toggle_class_sms'
      get 'toggle_exam_sms'
      get 'assign_students'
      get 'students'
      get 'check_verify_students'
      get 'get_chapters'
      get 'manage_student_subject'
      get 'manage_roll_number'
      get 'get_notifications'
      get 'get_timetable'
      get 'get_batch'
      post "import_students_excel"
      post 'make_active_class'
      post 'make_deactive_class'
      post 'verify_students'
      post 'recheck_duplicate_student'
      post 'accept_duplicate_student'
      post 'save_student_subjects'
      post 'manage_students'
      post 'save_roll_number'
      post 'upgrade_batch'
      #delete 'remove_students'
    end

    resources :sub_classes, only: [:index, :create, :show, :destroy] do
      member do
        get 'students'
        get 'remaining_students'
        post 'add_students'
        delete 'remove_student/:student_id' , to: "sub_classes#remove_student"
      end
    end
    
    resources :time_tables, only: [:index, :create, :show]
    
    resources :daily_teachs, except: [:update] do
      member do
        get 'get_catlogs'
        get 'class_absent_verification'
        post 'fill_catlog'
        post 'add_absent_student'
        post 'remove_absent_student'
        post 'update'
        post 'publish_absenty'
      end
    end
    resources :exams, except: [:update] do
      member do
        get 'get_catlogs'
        get 'verify_exam'
        get 'exam_conducted'
        get 'get_exam_info'
        get 'get_descendants'
        get 'group_exam_report'
        get 'manage_points'
        get 'get_chapters_points'
        post 'save_exam_points'
        post 'remove_exam_result'
        post 'update'
        post 'add_absunt_students'
        post 'add_absunt_student'
        post 'add_ignored_student'
        post 'remove_ignored_student'
        post 'remove_absunt_student'
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

  resources :time_tables, only: [] do
    collection do 
      get 'calender_index'
    end
    resources :time_table_classes, only: [:create, :index, :update, :destroy]
  end

  resources :chapters, only: [:index] do
    member do
      get 'get_points'
    end
  end
  
  resources :contacts#, only: [:create]
  get '/organisation_profile' => "organisations#show"
  get '/organisation_edit' => "organisations#edit"
  post '/update_organisation' => "organisations#update"
  get '/organisations/cources' => "organisations#organisation_cources"
  get 'organisations/get_classes' => "organisations#organisation_classes"
  get 'organisations/absenty_graph_report' => "organisations#absenty_graph_report"
  get 'organisations/exams_graph_report' => "organisations#exams_graph_report"
  get 'organisations/off_class_graph_report' => "organisations#off_class_graph_report"
  get 'organisations/get_class_rooms' => "organisations#get_class_rooms"
  get 'organisations/organisation_standards' => "organisations#organisation_standards"
  get 'organisations/standard/:standard_id/remaining_organisations' => "organisations#remaining_standard_organisations"
  get 'organisations/standard/:standard_id/disable_standard' => "organisations#disable_organisation_standard"
  get 'organisations/standard/:standard_id/enable_standard' => "organisations#enable_organisation_standard"
  get '/remaining_cources' => "organisations#remaining_cources"
  get '/organisations/get_sub_organisations' => "organisations#sub_organisations_list"
  get '/organisations/add_standards' => "organisations#add_standards"
  get '/organisations/get_clarks' => "organisations#get_clarks"
  get '/organisations/users/:user_id/get_roles' => "organisations#get_clark_roles"
  get "/organisations/users/:user_id/toggleEnable" => "organisations#toggle_enable_users"
  get "/organisations/users/:user_id/get_email" => "organisations#get_user_email"
  get "/organisations/get_standards" => "organisations#get_organisation_standards"
  get "/organisations/courses/:course_id/get_fee" => "organisations#get_standard_fee"
  get "/organisations/classes/:class_id/get_fee" => "organisations#get_class_fee"
  post "/organisations/courses/:course_id/update_fee" => "organisations#update_standard_fee"
  post "/organisations/classes/:class_id/update_fee" => "organisations#update_class_fee"
  post "/organisations/switch_organisation_standard" => "organisations#switch_organisation_standard"
  post '/organisations/remove_standard_from_organisation' => "organisations#remove_standard_from_organisation"
  post "/organisations/users/:user_id/update_clark_password" => "organisations#update_clark_password"
  post "/organisations/users/:user_id/update_roles" => "organisations#update_clark_roles"
  post "/organisations/users/create_organisation_clark" => "organisations#create_organisation_clark"
  post "/organisations/sub_organisation/launch_organisation" => "organisations#launch_sub_organisation"
  delete "/organisations/clarks/:user_id" => "organisations#delete_clark"
  delete "/organisations/sub_organisations/:sub_organisation_id" => "organisations#pull_back_sub_organisations"

  #get 'index' => "home#index"
  root 'home#index'
  
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
