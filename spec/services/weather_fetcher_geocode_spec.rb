require 'rails_helper'

RSpec.describe WeatherFetcher, type: :service do
  let(:wf) { described_class.new('loc') }

  describe '#geocode' do
    it 'returns [latitude, longitude] for a valid address' do
      fake = double('geo', latitude: 1.23, longitude: 4.56)
      allow(Geocoder).to receive(:search).with('loc').and_return([fake])
      expect(wf.send(:geocode, 'loc')).to eq([1.23, 4.56])
    end

    it 'returns nil when geocoding yields no results' do
      allow(Geocoder).to receive(:search).with('none').and_return([])
      expect(wf.send(:geocode, 'none')).to be_nil
    end
  end
end