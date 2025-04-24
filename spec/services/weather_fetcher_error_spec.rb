# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherFetcher, type: :service do
  describe 'error handling' do
    it 'returns an error hash when geocoding raises' do
      allow(Geocoder).to receive(:search).and_raise('BOOM')
      result = WeatherFetcher.call('any')
      expect(result).to be_a(Hash)
      expect(result[:error]).to match(/BOOM/)
    end
  end
end
