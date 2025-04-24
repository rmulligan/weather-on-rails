# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherFetcher, type: :service do
  let(:wf) { described_class.new('loc') }

  describe '#fetch_visualcrossing' do
    let(:coords) { [30.0, -90.0] }
    let(:api_key) { 'VCKEY' }

    before do
      allow(Rails.application.credentials).to receive(:visualcrossing_api_key).and_return(nil)
      ENV['VISUALCROSSING_API_KEY'] = api_key
    end

    it 'returns parsed weather when API call succeeds' do
      raw = {
        'currentConditions' => { 'temp' => 30, 'conditions' => 'rain' },
        'days' => [
          { 'datetime' => '2025-04-24', 'tempmax' => 35, 'tempmin' => 25, 'conditions' => 'rainy' }
        ]
      }
      resp = double('resp', success?: true, parsed_response: raw)
      expect(HTTParty).to receive(:get).with(%r{#{Regexp.escape(WeatherFetcher::VISUALCROSSING_URL)}/30\.0,-90\.0},
                                             anything).and_return(resp)
      result = wf.send(:fetch_visualcrossing, coords)
      expect(result[:provider]).to eq('VisualCrossing')
      expect(result[:current][:temp]).to eq(30)
      expect(result[:current][:high]).to eq(35)
      expect(result[:current][:low]).to eq(25)
      expect(result[:forecast].first[:summary]).to eq('rainy')
    end

    it 'returns nil when no API key is present' do
      ENV.delete('VISUALCROSSING_API_KEY')
      expect(wf.send(:fetch_visualcrossing, coords)).to be_nil
    end

    it 'returns nil when HTTP call fails' do
      ENV['VISUALCROSSING_API_KEY'] = api_key
      allow(HTTParty).to receive(:get).and_return(double(success?: false))
      expect(wf.send(:fetch_visualcrossing, coords)).to be_nil
    end
    context 'when only ENV key is set' do
      before do
        allow(Rails.application.credentials).to receive(:visualcrossing_api_key).and_return(nil)
        ENV['VISUALCROSSING_API_KEY'] = api_key
      end

      it 'uses ENV key and returns parsed data' do
        raw = {
          'currentConditions' => { 'temp' => 40, 'conditions' => 'snow' },
          'days' => [
            { 'datetime' => '2025-04-25', 'tempmax' => 45, 'tempmin' => 35, 'conditions' => 'snowy' }
          ]
        }
        resp = double('resp', success?: true, parsed_response: raw)
        expect(HTTParty).to receive(:get).and_return(resp)
        result = wf.send(:fetch_visualcrossing, coords)
        expect(result[:provider]).to eq('VisualCrossing')
        expect(result[:current][:temp]).to eq(40)
        expect(result[:forecast].first[:summary]).to eq('snowy')
      end
    end
  end
end
