# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherFetcher, type: :service do
  let(:zip) { '99999' }
  let(:addr) { 'Somewhere, XY' }
  let(:zip_data) { [1.1, 2.2, 'ZIP City, ZP, 99999'] }
  let(:addr_geo) do
    double('geo', latitude: 3.3, longitude: 4.4,
                  data: { 'address' => { 'city' => 'AddrCity', 'state' => 'AS', 'postcode' => '12345' } })
  end

  before do
    # Simulate production environment for testing fetch_and_cache logic
    # Clear cache to avoid test interference
    Rails.cache.clear
    allow(Rails.env).to receive(:test?).and_return(false)
    allow(Rails.application.credentials).to receive(:openweathermap_api_key).and_return(nil)
    allow(ENV).to receive(:[]).with('OPENWEATHERMAP_API_KEY').and_return(nil)
    allow(Rails.application.credentials).to receive(:visualcrossing_api_key).and_return(nil)
    allow(ENV).to receive(:[]).with('VISUALCROSSING_API_KEY').and_return(nil)
  end

  context 'ZIP code branch with OpenWeatherMap' do
    before do
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_us_zip).with(zip).and_return(zip_data)
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_openweathermap)
        .and_return(provider: 'OWM', current: { temp: 5, high: 6, low: 4, summary: 'fine' }, forecast: [])
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_visualcrossing).and_return(nil)
    end

    it 'uses OpenWeatherMap for ZIP and sets lat, lon, and place_name' do
      res = WeatherFetcher.call(zip)
      expect(res[:provider]).to eq('OWM')
      expect(res[:lat]).to eq(1.1)
      expect(res[:lon]).to eq(2.2)
      expect(res[:place_name]).to eq('ZIP City, ZP, 99999')
    end
  end

  context 'ZIP code branch falls back to VisualCrossing' do
    before do
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_us_zip).with(zip).and_return(zip_data)
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_openweathermap).and_return(nil)
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_visualcrossing)
        .and_return(provider: 'VC', current: { temp: 7, high: 8, low: 6, summary: 'rain' }, forecast: [])
    end

    it 'uses VisualCrossing when OpenWeatherMap is unavailable' do
      res = WeatherFetcher.call(zip)
      expect(res[:provider]).to eq('VC')
      expect(res[:place_name]).to eq('ZIP City, ZP, 99999')
    end
  end

  context 'ZIP code branch yields no data' do
    before do
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_us_zip).with(zip).and_return(zip_data)
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_openweathermap).and_return(nil)
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_visualcrossing).and_return(nil)
    end

    it 'returns an error when no provider data is available' do
      res = WeatherFetcher.call(zip)
      expect(res[:error]).to eq('Weather data unavailable')
      expect(res[:lat]).to eq(1.1)
      expect(res[:lon]).to eq(2.2)
    end
  end

  context 'address branch uses geocoding' do
    before do
      allow(Geocoder).to receive(:search).with(addr).and_return([addr_geo])
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_openweathermap)
        .and_return(provider: 'OWM2', current: { temp: 9, high: 10, low: 8, summary: 'sun' }, forecast: [])
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_visualcrossing).and_return(nil)
    end

    it 'geocodes address and sets correct place_name and coordinates' do
      res = WeatherFetcher.call(addr)
      expect(res[:provider]).to eq('OWM2')
      expect(res[:lat]).to eq(3.3)
      expect(res[:lon]).to eq(4.4)
      expect(res[:place_name]).to eq('AddrCity, AS, 12345')
    end
  end

  context 'address branch falls back to VisualCrossing' do
    before do
      allow(Geocoder).to receive(:search).with(addr).and_return([addr_geo])
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_openweathermap).and_return(nil)
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_visualcrossing)
        .and_return(provider: 'VC2', current: { temp: 21, high: 22, low: 20, summary: 'windy' }, forecast: [])
    end

    it 'uses VisualCrossing when OpenWeatherMap is unavailable' do
      res = WeatherFetcher.call(addr)
      expect(res[:provider]).to eq('VC2')
      expect(res[:lat]).to eq(3.3)
      expect(res[:lon]).to eq(4.4)
      expect(res[:place_name]).to eq('AddrCity, AS, 12345')
    end
  end

  context 'address branch yields no data' do
    before do
      allow(Geocoder).to receive(:search).with(addr).and_return([addr_geo])
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_openweathermap).and_return(nil)
      allow_any_instance_of(WeatherFetcher).to receive(:fetch_visualcrossing).and_return(nil)
    end

    it 'returns an error when no provider data is available' do
      res = WeatherFetcher.call(addr)
      expect(res[:error]).to eq('Weather data unavailable')
      expect(res[:lat]).to eq(3.3)
      expect(res[:lon]).to eq(4.4)
    end
  end

  context 'invalid address branch error', without_http: true do
    before do
      allow(Rails.env).to receive(:test?).and_return(false)
      allow(Geocoder).to receive(:search).with('badaddr').and_return([])
    end

    it 'returns geocoding error for unknown address' do
      res = WeatherFetcher.call('badaddr')
      expect(res[:error]).to eq('Could not geocode location')
    end
  end
end
