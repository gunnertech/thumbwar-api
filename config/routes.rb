Rails.application.routes.draw do
  resources :devices

  resources :challenges

  get "twitter_oauth", to: "users#twitter_oauth"
  get "facebook_oauth", to: "users#facebook_oauth"
  post "login", to: "users#login"
  delete "logout", to: "users#logout"

  resources :users do
    resources :thumbwars, only: :index

    post "follow"
    post "unfollow"

    get ":view", to: "users#index"
  end

  resources :thumbwars do
    resources :comments, only: [:create, :index]

    post "watch"
    post "unwatch"
    post "push"

    get ":view", to: "thumbwars#index"
  end

  resources :alerts, only: [:update, :index, :show]
end
