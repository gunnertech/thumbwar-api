ThumbwarApi::Application.routes.draw do
  post "register", to: "users#register"
  put "verify", to: "users#verify"
  post "login", to: "users#login"
  delete "logout", to: "users#logout"
  
  resources :users do
    resources :thumbwars, only: :index
    
    post "follow"
    post "unfollow"
    
    get ":view", to: "users#index"
  end
  
  resources :thumbwars do
    resources :comments, only: :create
    
    post "watch"
    post "unwatch"
    post "push"
    
    get ":view", to: "thumbwars#index"
  end
  
  resources :alerts, only: [:update, :index, :show]
end