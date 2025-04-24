# frozen_string_literal: true

# WeatherFetcher fetches weather data for a given US address or ZIP code.
# It uses Geocoder for geocoding, OpenWeatherMap as the primary API, and Visual Crossing as a backup.
# Results are cached using Rails low-level caching.
#
# Usage:
#   WeatherFetcher.call("90210")
#   WeatherFetcher.call("1600 Pennsylvania Ave NW, Washington, DC")
class WeatherFetcher
  require 'geocoder'
  require 'httparty'

  OPENWEATHERMAP_URL = "https://api.openweathermap.org/data/2.5/onecall"
  VISUALCROSSING_URL = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline"

  def self.call(location)
    new(location).fetch
  end

  def initialize(location)
    @location = location
  end

  def fetch
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      coords = geocode(@location)
      raise "Could not geocode location" unless coords
      lat, lon = coords
      data = fetch_openweathermap(coords) || fetch_visualcrossing(coords) || { error: "Weather data unavailable" }
      data[:lat] = lat
      data[:lon] = lon
      data
    end
  rescue => e
    { error: e.message }
  end

  private

  def geocode(location)
    results = Geocoder.search(location)
    return nil if results.empty?
    lat = results.first.latitude
    lon = results.first.longitude
    [lat, lon]
  end

  def fetch_openweathermap(coords)
    api_key = Rails.application.credentials.openweathermap_api_key
    return nil unless api_key
    lat, lon = coords
    resp = HTTParty.get(OPENWEATHERMAP_URL, query: {
      lat: lat, lon: lon, units: 'imperial', appid: api_key, exclude: 'minutely,alerts'
    })
    return nil unless resp.success?
    parse_openweathermap(resp.parsed_response)
  rescue
    nil
  end

  def fetch_visualcrossing(coords)
    api_key = Rails.application.credentials.visualcrossing_api_key
    return nil unless api_key
    lat, lon = coords
    url = "#{VISUALCROSSING_URL}/#{lat},#{lon}"
    resp = HTTParty.get(url, query: {
      unitGroup: 'us', key: api_key, include: 'days,current', contentType: 'json'
    })
    return nil unless resp.success?
    parse_visualcrossing(resp.parsed_response)
  rescue
    nil
  end

  def parse_openweathermap(data)
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

  def parse_visualcrossing(data)
    days = data['days'] || []
    {
      provider: 'VisualCrossing',
      current: {
        temp: data.dig('currentConditions', 'temp'),
        high: days[0] && days[0]['tempmax'],
        low: days[0] && days[0]['tempmin'],
        summary: data.dig('currentConditions', 'conditions')
      },
      forecast: days.first(3).map do |day|
        {
          date: Date.parse(day['datetime']),
          high: day['tempmax'],
          low: day['tempmin'],
          summary: day['conditions']
        }
      end
    }
  end

  def cache_key
    "weather:#{@location.to_s.downcase.strip.gsub(/\s+/, '-')}:v1"
  end
end
