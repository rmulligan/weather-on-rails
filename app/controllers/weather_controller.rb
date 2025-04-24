class WeatherController < ApplicationController
  def index
    @location = params[:location]
    @weather = WeatherFetcher.call(@location) if @location.present?
  end
end
