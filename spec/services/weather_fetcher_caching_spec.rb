require 'rails_helper'

RSpec.describe WeatherFetcher, type: :service do
  describe 'caching behavior' do
    let(:location) { '99999' }

    before do
      # Clear cache before tests
      Rails.cache.clear
      # Stub geocoding to avoid external calls
      fake_geo = double('geo', latitude: 10.0, longitude: 20.0, data: { 'address' => { 'city' => 'Foo', 'state' => 'Bar', 'postcode' => location } })
      allow(Geocoder).to receive(:search).with(location).and_return([fake_geo])
      # Stub API calls
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_openweathermap)
        .and_return(provider: 'Test', current: { temp: 1, high: 2, low: 0, summary: 'cold' }, forecast: [{ date: Date.today, high: 2, low: 0, summary: 'cold' }])
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_visualcrossing).and_return(nil)
    end

    it 'fetches live data on first call and caches it' do
      first = WeatherFetcher.call(location)
      expect(first[:cached]).to be false
      expect(first[:fetched_at]).to be_a(Time).or be_a(ActiveSupport::TimeWithZone)
      second = WeatherFetcher.call(location)
      expect(second[:cached]).to be true
      expect(second[:fetched_at]).to eq(first[:fetched_at])
      expect(second[:current][:temp]).to eq(first[:current][:temp])
    end
  end
end