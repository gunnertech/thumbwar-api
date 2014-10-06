Thumbwar::Application.routes.draw do
  devise_scope :user do
    post "registration", to: "registration#create"
    post "session", to: "session#create"
    get "session", to: "session#show"
    delete "session", to: "session#destroy"
  end
  devise_for(:users, :controllers => { :sessions => "api/sessions", :registrations => "api/registration"})
end