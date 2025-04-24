# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherFetcher, type: :service do
  let(:wf) { described_class.new('loc') }

  describe '#fetch_openweathermap' do
    let(:coords) { [10.0, 20.0] }
    let(:api_key) { 'APIKEY' }

    before do
      # stub credentials
      allow(Rails.application.credentials).to receive(:openweathermap_api_key).and_return(api_key)
      ENV.delete('OPENWEATHERMAP_API_KEY')
    end

    it 'returns parsed weather when API call succeeds' do
      now = Time.now.to_i
      raw = {
        'current' => { 'temp' => 50, 'weather' => [{ 'description' => 'clear sky' }] },
        'daily' => [
          { 'dt' => now, 'temp' => { 'max' => 55, 'min' => 45 }, 'weather' => [{ 'description' => 'sunny' }] }
        ]
      }
      resp = double('resp', success?: true, parsed_response: raw)
      expect(HTTParty).to receive(:get).with(WeatherFetcher::OPENWEATHERMAP_URL, anything).and_return(resp)
      result = wf.send(:fetch_openweathermap, coords)
      expect(result[:provider]).to eq('OpenWeatherMap')
      expect(result[:current][:temp]).to eq(50)
      expect(result[:current][:high]).to eq(55)
      expect(result[:current][:low]).to eq(45)
      expect(result[:forecast].size).to eq(1)
      expect(result[:forecast].first[:summary]).to eq('sunny')
    end

    it 'returns nil when no API key is present' do
      allow(Rails.application.credentials).to receive(:openweathermap_api_key).and_return(nil)
      expect(wf.send(:fetch_openweathermap, coords)).to be_nil
    end

    it 'returns nil when HTTP call fails' do
      allow(HTTParty).to receive(:get).and_return(double(success?: false))
      expect(wf.send(:fetch_openweathermap, coords)).to be_nil
    end
    context 'when only ENV key is set' do
      before do
        allow(Rails.application.credentials).to receive(:openweathermap_api_key).and_return(nil)
        ENV['OPENWEATHERMAP_API_KEY'] = api_key
      end

      it 'uses ENV key and returns parsed data' do
        now = Time.now.to_i
        raw = {
          'current' => { 'temp' => 70, 'weather' => [{ 'description' => 'cloudy' }] },
          'daily' => [
            { 'dt' => now, 'temp' => { 'max' => 75, 'min' => 65 }, 'weather' => [{ 'description' => 'rain' }] }
          ]
        }
        resp = double('resp', success?: true, parsed_response: raw)
        expect(HTTParty).to receive(:get).and_return(resp)
        result = wf.send(:fetch_openweathermap, coords)
        expect(result[:provider]).to eq('OpenWeatherMap')
        expect(result[:current][:temp]).to eq(70)
      end
    end
  end
end
