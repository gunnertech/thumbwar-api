ThumbwarApi::Application.routes.draw do
  post "register", to: "users#register"
  post "login", to: "users#login"
  post "logout", to: "users#logout"
  
  resources :users do
    resources :thumbwars, only: :index
    
    post "follow", to: "users#follow"
    post "unfollow", to: "users#unfollow"
    get ":view", to: "users#index"
  end
  
  resources :thumbwars do
    post "watch", to: "thumbwars#watch"
    post "unwatch", to: "thumbwars#unwatch"
    get ":view", to: "thumbwars#index"
    post "comment", to: "thumbwars#comment"
  end
end