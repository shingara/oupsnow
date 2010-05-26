Oupsnow::Application.routes.draw do |map|
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  devise_for :users

  namespace :admin do

    match '/' => 'functions#index', :as => 'root'

    resources :functions do
      collection do
        put :update_all
      end
    end

    resources :users do
      collection do
        put :update_all
      end
    end

    resources :states do
      collection do
        put :update_all
      end
    end

    resources :priorities
  end

  resources :users
  resources :projects do
    member do
      get :delete
      put :overview
    end

    resources :milestones

    resources :tickets do
      member do
        get :edit_main_description
        get :watch
        put :unwatch
        put :update_main_description
      end

      resources :ticket_updates, :only => [:edit, :update]
    end

    #project.settings '/settings', :controller => 'project_members', :action => 'index'
    namespace :settings do
      resources :project_members do
        collection do
          put :update_all
        end
      end
    end
  end

  root :to => 'projects#index'
end
