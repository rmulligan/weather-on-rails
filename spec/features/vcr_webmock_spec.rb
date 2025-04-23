require 'httparty'

RSpec.describe 'VCR and WebMock', type: :feature do
  it 'records and replays HTTP interactions', :vcr do
    response = HTTParty.get('https://jsonplaceholder.typicode.com/todos/1')
    expect(response.code).to eq(200)
    expect(response.parsed_response).to include('title')
  end
end