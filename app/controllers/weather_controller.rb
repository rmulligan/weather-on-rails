class WeatherController < ApplicationController
  def index
    @location = params[:location]
    begin
      @weather = WeatherFetcher.call(@location) if @location.present?
    rescue => e
      @weather = { error: "An unexpected error occurred: #{e.message}" }
    end
  end
end
