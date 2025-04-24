# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherFetcher, type: :service do
  let(:wf) { described_class.new('any') }

  describe '#parse_openweathermap' do
    it 'parses current and daily weather data' do
      now = Time.now.to_i
      data = {
        'current' => { 'temp' => 42, 'weather' => [{ 'description' => 'drizzle' }] },
        'daily' => [
          { 'dt' => now, 'temp' => { 'max' => 45, 'min' => 38 }, 'weather' => [{ 'description' => 'clouds' }] }
        ]
      }
      parsed = wf.send(:parse_openweathermap, data)
      expect(parsed[:provider]).to eq('OpenWeatherMap')
      expect(parsed[:current][:temp]).to eq(42)
      expect(parsed[:current][:high]).to eq(45)
      expect(parsed[:current][:low]).to eq(38)
      expect(parsed[:current][:summary]).to eq('drizzle')
      expect(parsed[:forecast].first[:high]).to eq(45)
      expect(parsed[:forecast].first[:low]).to eq(38)
      expect(parsed[:forecast].first[:summary]).to eq('clouds')
    end
  end

  describe '#parse_visualcrossing' do
    it 'parses currentConditions and days array' do
      data = {
        'currentConditions' => { 'temp' => 55, 'conditions' => 'fog' },
        'days' => [
          { 'datetime' => '2025-04-26', 'tempmax' => 60, 'tempmin' => 50, 'conditions' => 'mist' }
        ]
      }
      parsed = wf.send(:parse_visualcrossing, data)
      expect(parsed[:provider]).to eq('VisualCrossing')
      expect(parsed[:current][:temp]).to eq(55)
      expect(parsed[:current][:high]).to eq(60)
      expect(parsed[:current][:low]).to eq(50)
      expect(parsed[:current][:summary]).to eq('fog')
      expect(parsed[:forecast].first[:summary]).to eq('mist')
    end
  end

  describe '#cache_key' do
    it 'normalizes location into a cache key slug' do
      wf2 = described_class.new('  Abc 123  ')
      expect(wf2.send(:cache_key)).to eq('weather:abc-123:v1')
    end
  end

  describe '#fetch_us_zip' do
    it 'rescues and returns nil on HTTP exceptions' do
      allow(HTTParty).to receive(:get).and_raise(StandardError)
      expect(wf.send(:fetch_us_zip, '00000')).to be_nil
    end
  end
end
