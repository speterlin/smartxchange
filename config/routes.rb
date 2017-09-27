Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  get 'about' => 'static_pages#about'
  get 'contact' => 'static_pages#contact'
  get 'login'   => 'sessions#new'
  get 'signup'  => 'users#new'
  get 'auth/linkedin/callback' => 'sessions#omniauth_callback'
  root to: 'users#new'

  resource :session

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
    get 'mandarin_chinese', on: :collection
    get 'map', on: :collection
    get 'exchange', on: :collection
    get 'remove_image', on: :member
    get 'delete_linkedin', on: :member
    get 'email_match/:matches_token/:match_id', to: 'users#email_match', as: 'email_match'
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
    resources :materials, only: [:create, :destroy]
  end

  resources :conversations, controller: :chat_rooms, only: [:new, :create, :show, :index, :destroy]
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
