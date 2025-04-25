# frozen_string_literal: true

# Controller for serving precipitation tiles via the OpenWeatherMap API
class TilesController < ApplicationController
  require 'httparty'

  # Proxy precipitation tiles from OpenWeatherMap, keeping the API key on the server
  # URL params: z, x, y (tile coordinates)
  def openweathermap_precipitation
    z = params[:z]
    x = params[:x]
    y = params[:y]
    api_key = Rails.application.credentials.openweathermap_api_key || ENV.fetch('OPENWEATHERMAP_API_KEY', nil)
    return head :not_found unless api_key

    tile_url = "https://tile.openweathermap.org/map/precipitation_new/#{z}/#{x}/#{y}.png?appid=#{api_key}"
    resp = HTTParty.get(tile_url)
    if resp.success?
      send_data resp.body, type: 'image/png', disposition: 'inline'
    else
      head :bad_gateway
    end
  rescue StandardError => e
    Rails.logger.error("Error proxying tile #{tile_url}: #{e.message}")
    head :bad_gateway
  end
end
