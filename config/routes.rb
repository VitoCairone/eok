Rails.application.routes.draw do
  root 'welcome#index'

  resources :thoughts

  resources :questions do
    get 'voiced', on: :collection
    get 'passed', on: :collection
  end

  resources :choices, only: [:index, :show]

  resources :voices, except: [:new, :edit, :update]

  get '/auth/:provider/callback', to: 'sessions#create'

  delete '/logout', to: 'sessions#destroy'

  # For details on the DSL available within this file,
  # see http://guides.rubyonrails.org/routing.html

end
