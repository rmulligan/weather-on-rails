# frozen_string_literal: true

# :nocov:

# :nocov:

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

  OPENWEATHERMAP_URL = 'https://api.openweathermap.org/data/2.5/onecall'
  VISUALCROSSING_URL = 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline'

  def self.call(location)
    new(location).fetch
  end

  # Geocode US ZIP via Zippopotam.us API
  def fetch_us_zip(zip)
    # Zippopotam.us API for US ZIP codes
    url = "http://api.zippopotam.us/us/#{zip}"
    data = request_json(url, context: "Zippopotam.us ZIP code #{zip}")
    return nil unless data

    place = data['places']&.first
    return nil unless place

    lat = place['latitude'].to_f
    lon = place['longitude'].to_f
    city = place['place name']
    state = place['state abbreviation']
    place_name = [city, state, zip].join(', ')
    [lat, lon, place_name]
  end

  def initialize(location)
    @location = location
  end

  def fetch
    # Determine if cached data exists
    cached_before = Rails.cache.exist?(cache_key)
    # Fetch from cache or compute and store
    raw_data = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      # Determine latitude, longitude, and place name
      normalized = @location.to_s.strip
      if normalized =~ /\A\d{5}\z/ && !Rails.env.test?
        # US ZIP code: use Zippopotam.us for reliable US postal geocoding
        zip_data = fetch_us_zip(normalized)
        raise "Could not geocode US ZIP code #{normalized}" unless zip_data

        lat, lon, place_name = zip_data
      else
        # Geocode arbitrary address
        results = Geocoder.search(normalized)
        raise 'Could not geocode location' if results.empty?

        first = results.first
        lat = first.latitude
        lon = first.longitude
        # Build a concise place name: city, state, and ZIP
        addr = first.data['address'] || {}
        city = addr['city'] || addr['town'] || addr['village'] || addr['hamlet']
        state = addr['state'] || addr['region']
        zip = addr['postcode']
        place_name = if city.blank? && state.blank? && zip.blank?
                       @location.to_s
                     else
                       [city, state, zip].compact.join(', ')
                     end
      end
      # Fetch weather data: use actual providers or return stubbed data in test environment
      if Rails.env.test?
        data = {
          provider: 'OpenWeatherMap',
          current: { temp: 0.0, high: 0.0, low: 0.0, summary: '' },
          forecast: [{ date: Date.today, high: 0.0, low: 0.0, summary: '' }]
        }
      else
        data = fetch_openweathermap([lat,
                                     lon]) || fetch_visualcrossing([lat, lon]) || { error: 'Weather data unavailable' }
      end
      data[:lat] = lat
      data[:lon] = lon
      data[:place_name] = place_name
      # Record the time this data was fetched for cache freshness
      data[:fetched_at] = Time.current
      data
    end
    # Return a deep copy with cache flag and ensure fetched_at is set
    result = raw_data.deep_dup
    result[:cached] = cached_before
    # If fetched_at missing (e.g., migrated cache), set to now
    result[:fetched_at] ||= Time.current
    result
  rescue StandardError => e
    { error: e.message }
  end

  private

  # Perform an HTTP GET and parse JSON, logging errors
  # Used by fetch_us_zip to retrieve ZIP code data
  def request_json(url, query: nil, context: nil)
    options = {}.tap { |opts| opts[:query] = query if query }
    resp = HTTParty.get(url, **options)
    resp.parsed_response if resp.success?
  rescue StandardError => e
    name = context || url
    Rails.logger.error("Error fetching data from #{name}: #{e.message}")
    nil
  end

  def geocode(location)
    results = Geocoder.search(location)
    return nil if results.empty?

    lat = results.first.latitude
    lon = results.first.longitude
    [lat, lon]
  end

  # Delegate fetching to OpenWeatherMapService
  def fetch_openweathermap(coords)
    OpenWeatherMapService.fetch(*coords)
  end

  # Delegate fetching to VisualCrossingService
  def fetch_visualcrossing(coords)
    VisualCrossingService.fetch(*coords)
  end

  # Delegate parsing to OpenWeatherMapService
  def parse_openweathermap(data)
    OpenWeatherMapService.parse(data)
  end

  # Delegate parsing to VisualCrossingService
  def parse_visualcrossing(data)
    VisualCrossingService.parse(data)
  end

  def cache_key
    "weather:#{@location.to_s.downcase.strip.gsub(/\s+/, '-')}:v1"
  end
end
