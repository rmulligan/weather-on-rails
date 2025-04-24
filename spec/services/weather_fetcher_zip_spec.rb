require 'rails_helper'
require 'webmock/rspec'

RSpec.describe WeatherFetcher, '#fetch_us_zip', type: :service do
  let(:zip) { '90210' }
  let(:zip_response) do
    {
      'post code' => zip,
      'country' => 'United States',
      'places' => [
        {
          'place name' => 'Beverly Hills',
          'longitude' => '-118.4065',
          'latitude' => '34.0901',
          'state abbreviation' => 'CA'
        }
      ]
    }
  end

  before do
    stub_request(:get, "http://api.zippopotam.us/us/#{zip}")
      .to_return(status: 200, body: zip_response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  subject { described_class.new(zip) }

  it 'returns latitude, longitude, and place_name array for valid ZIP' do
    result = subject.send(:fetch_us_zip, zip)
    expect(result).to eq([34.0901, -118.4065, "Beverly Hills, CA, #{zip}"])
  end

  it 'returns nil for non-existent ZIP' do
    stub_request(:get, "http://api.zippopotam.us/us/00000").to_return(status: 404)
    expect(subject.send(:fetch_us_zip, '00000')).to be_nil
  end
end