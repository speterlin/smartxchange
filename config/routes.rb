Rails.application.routes.draw do
  get 'about' => 'static_pages#about'
  get 'contact' => 'static_pages#contact'
  get 'login'   => 'sessions#new'
  get 'signup'  => 'users#new'
  get 'auth/linkedin/callback' => 'sessions#create_linkedin'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  root to: 'users#new'

  # since there is only one session everything is on collection, there are no session/1...session/2 for example
  resource :session do
    get 'new_linkedin', on: :collection
    get 'existing_linkedin', on: :collection
    get 'add_linkedin', on: :collection
    get 'update_linkedin', on: :collection
    delete 'delete_linkedin', on: :collection
  end

  resources :users do
    get 'all', on: :collection
    get 'active', on: :collection
    get 'chat_bots', on: :collection
    get 'tutors', on: :collection
    get 'spanish', on: :collection
    get 'italian', on: :collection
    get 'french', on: :collection
    get 'german', on: :collection
    get 'english', on: :collection
    get 'map', on: :collection
    get 'exchange', on: :collection
    get 'email_match/:matches_token/:match_id', to: 'users#email_match'
    get 'settings' => 'settings#show'
    get 'reset_password' => 'settings#reset_password', on: :collection
    post 'create_password' => 'settings#create_password', on: :collection
    resources :settings, only: [] do
      get 'change_password', on: :collection
      patch 'update_password',  on: :collection
      get 'email_subscription', on: :collection
      patch 'update_subscription', on: :collection
      get 'activate', on: :collection
      get 'deactivate', on: :collection
      get 'downgrade', on: :collection
      get 'activate_account/:activation_token', on: :collection, to: 'settings#activate_account', as: 'activate_account'
    end
    resources :reviews, except: [:show]
  end

  resources :chat_rooms, only: [:new, :create, :show, :index, :destroy]
  resources :messages, only: [:create]

  resources :boards, only: [:show]
  resources :posts, only: [:create, :update, :destroy] do
    post "upvote", on: :member
    post "downvote", on: :member
    post "follow", on: :member
    post "unfollow", on: :member
    get "followers", on: :member
  end
  resources :comments, only: [:create, :update, :destroy]

  resources :transactions, only: [:new, :create] do
    post "create_customer", on: :collection
  end

  mount ActionCable.server => '/cable'

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
