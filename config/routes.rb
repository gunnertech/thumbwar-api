ThumbwarApi::Application.routes.draw do
  post "register", to: "users#register"
  post "login", to: "users#login"
  delete "logout", to: "users#logout"
  
  resources :users do
    resources :thumbwars, only: :index
    
    post "follow"
    post "unfollow"
    
    get ":view", to: "users#index"
  end
  
  resources :thumbwars do
    post "watch"
    post "unwatch"
    post "comment"
    post "push"
    
    get ":view", to: "thumbwars#index"
  end
  
  resources :alerts, only: [:update, :index]
end