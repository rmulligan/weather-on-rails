# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'weather#index'
  get 'weather', to: 'weather#index'

  # Proxy OpenWeatherMap precipitation tiles to keep API key server-side
  get 'tiles/openweathermap/precipitation/:z/:x/:y.png',
      to: 'tiles#openweathermap_precipitation',
      as: :openweathermap_precipitation_tile,
      defaults: { format: 'png' }
end
