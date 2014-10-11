Thumbwar::Application.routes.draw do
  resources :users do
    post "follow", to: "users#follow"
  end
  post "login", to: "users#login"
  post "logout", to: "users#logout"
end