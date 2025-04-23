require 'rails_helper'

RSpec.describe WeatherFetcher, type: :service do
  let(:zip) { '90210' } # Beverly Hills, CA
  let(:address) { '1600 Pennsylvania Ave NW, Washington, DC' }
  let(:invalid_location) { 'notarealplace12345' }

  context 'with a valid ZIP code', :vcr do
    it 'returns weather data' do
      result = WeatherFetcher.call(zip)
      expect(result[:current][:temp]).to be_a(Numeric)
      expect(result[:current][:high]).to be_a(Numeric)
      expect(result[:current][:low]).to be_a(Numeric)
      expect(result[:forecast]).to be_an(Array)
      expect(result[:forecast].size).to be >= 1
      expect(result[:provider]).to be_in(['OpenWeatherMap', 'VisualCrossing'])
    end
  end

  context 'with a valid address', :vcr do
    it 'returns weather data' do
      result = WeatherFetcher.call(address)
      expect(result[:current][:temp]).to be_a(Numeric)
      expect(result[:current][:high]).to be_a(Numeric)
      expect(result[:current][:low]).to be_a(Numeric)
      expect(result[:forecast]).to be_an(Array)
      expect(result[:forecast].size).to be >= 1
      expect(result[:provider]).to be_in(['OpenWeatherMap', 'VisualCrossing'])
    end
  end

  context 'with an invalid location', :vcr do
    it 'returns an error' do
      result = WeatherFetcher.call(invalid_location)
      expect(result[:error]).to be_present
    end
  end
end
