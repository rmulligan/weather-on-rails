# frozen_string_literal: true

# Service for fetching and parsing weather data from OpenWeatherMap
class OpenWeatherMapService
  require 'httparty'

  # URL endpoint for One Call API
  URL = 'https://api.openweathermap.org/data/2.5/onecall'

  # Fetches weather data for given latitude and longitude.
  # Returns parsed hash on success, or nil on failure or missing API key.
  def self.fetch(lat, lon)
    api_key = Rails.application.credentials.openweathermap_api_key || ENV.fetch('OPENWEATHERMAP_API_KEY', nil)
    return nil unless api_key

    resp = HTTParty.get(URL, query: {
                          lat: lat,
                          lon: lon,
                          units: 'imperial',
                          appid: api_key,
                          exclude: 'minutely,alerts'
                        })
    return nil unless resp.success?

    parse(resp.parsed_response)
  rescue HTTParty::Error, JSON::ParserError => e
    Rails.logger.error("Error fetching data from OpenWeatherMap: #{e.message}")
    nil
  end

  # Parses raw JSON data into standardized weather hash
  def self.parse(data)
    {
      provider: 'OpenWeatherMap',
      current: {
        temp: data.dig('current', 'temp'),
        high: data.dig('daily', 0, 'temp', 'max'),
        low: data.dig('daily', 0, 'temp', 'min'),
        summary: data.dig('current', 'weather', 0, 'description')
      },
      forecast: data['daily'].first(3).map do |day|
        {
          date: Time.at(day['dt']).to_date,
          high: day.dig('temp', 'max'),
          low: day.dig('temp', 'min'),
          summary: day.dig('weather', 0, 'description')
        }
      end
    }
  end
end
