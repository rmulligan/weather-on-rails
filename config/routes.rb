Rails.application.routes.draw do
  root to: 'weather#index'
  get 'weather', to: 'weather#index'
end
