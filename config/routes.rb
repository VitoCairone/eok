Rails.application.routes.draw do
  resources :voices
  resources :choices
  resources :questions
  root 'welcome#index'

  resources :thoughts

  get '/auth/:provider/callback', to: 'sessions#create'

  delete '/logout', to: 'sessions#destroy'

  # For details on the DSL available within this file,
  # see http://guides.rubyonrails.org/routing.html

end
