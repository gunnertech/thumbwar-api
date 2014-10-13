ThumbwarApi::Application.routes.draw do
  resources :users do
    post "follow", to: "users#follow"
    get "followers", to: "users#followers"
    resources :thumbwars, only: :index
  end
  post "register", to: "users#create"
  post "login", to: "users#login"
  post "logout", to: "users#logout"
  
  resources :thumbwars do
    post "watch", to: "thumbwars#watch"
    get "watchers", to: "thumbwars#watchers"
  end
end