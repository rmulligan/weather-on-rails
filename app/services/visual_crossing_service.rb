# frozen_string_literal: true

# Service for fetching and parsing weather data from Visual Crossing
class VisualCrossingService
  require 'httparty'

  # Base URL for Visual Crossing Timeline API
  URL = 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline'

  # Fetches weather data for given latitude and longitude.
  # Returns parsed hash on success, or nil on failure or missing API key.
  def self.fetch(lat, lon)
    api_key = Rails.application.credentials.visualcrossing_api_key || ENV.fetch('VISUALCROSSING_API_KEY', nil)
    return nil unless api_key

    resp = HTTParty.get("#{URL}/#{lat},#{lon}", query: {
                          unitGroup: 'us',
                          key: api_key,
                          include: 'days,current',
                          contentType: 'json'
                        })
    return nil unless resp.success?

    parse(resp.parsed_response)
  rescue HTTParty::Error, JSON::ParserError => e
    Rails.logger.error("Error fetching data from Visual Crossing: #{e.message}")
    nil
  end

  # Parses raw JSON data into standardized weather hash
  def self.parse(data)
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
end
