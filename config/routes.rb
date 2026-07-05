Rails.application.routes.draw do
  root "home#show"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :agent_messages, only: :create
    end
  end

  get "webhooks/whatsapp" => "webhooks/whatsapp#verify"
  post "webhooks/whatsapp" => "webhooks/whatsapp#create"
end
