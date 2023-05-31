Rails.application.routes.draw do
  resources :mpesas
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/mpesa/stkpush', to: 'mpesas#stkpush'

  # get access token
  post '/mpesa/access_token', to: 'mpesas#my_custom_token'
  post '/mpesa/callback_url', to: 'mpesas#callback_url'

  post '/mpesa/polling_payment', to: 'mpesas#polling_request'
end
