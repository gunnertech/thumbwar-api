ThumbwarApi::Application.routes.draw do
  resources :users do
    post "follow", to: "users#follow"
    get "followers", to: "users#followers"
    resources :thumbwars, only: :index
  end
  post "register", to: "users#register"
  post "login", to: "users#login"
  post "logout", to: "users#logout"
  
  resources :thumbwars do
    post "watch", to: "thumbwars#watch"
    get "watchers", to: "thumbwars#watchers"
    post "comment", to: "thumbwars#comment"
  end
end