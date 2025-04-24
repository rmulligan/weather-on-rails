require 'rails_helper'

RSpec.describe 'Weather', type: :request do
  describe 'GET /weather' do
    context 'without location param' do
      it 'renders the page without weather data' do
        get weather_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(ENV.fetch('PAGE_NAME', 'Weather Lookup'))
        expect(response.body).not_to include('Data retrieved at:')
      end
    end

    context 'with location param and successful fetch' do
      let(:fake_weather) do
        {
          place_name: 'Test City, TS, 12345',
          fetched_at: Time.current,
          cached: false,
          provider: 'TestProvider',
          current: { temp: 60, high: 65, low: 55, summary: 'clear sky' },
          forecast: [
            { date: Date.today, high: 61, low: 51, summary: 'sunny' }
          ],
          lat: 10.0,
          lon: 20.0
        }
      end

      before do
        allow(WeatherFetcher).to receive(:call).with('12345').and_return(fake_weather)
        get weather_path, params: { location: '12345' }
      end

      it 'renders the fetched place name, provider, fetched-at tag, live pill, and no expiration on first fetch' do
        expect(response.body).to include('Weather for Test City, TS, 12345')
        expect(response.body).to include('Powered by TestProvider')
        expect(response.body).to include('id="weather-fetched-at"')
        expect(response.body).to include('data-timestamp="')
        expect(response.body).to include('Live data')
        expect(response.body).not_to include('<span id="weather-expires-at"')
      end

      it 'renders the current temperature and summary' do
        expect(response.body).to match(/60°F/)
        expect(response.body).to include('clear sky')
      end

      it 'includes the map container' do
        expect(response.body).to include('id="weather-map"')
      end

      it 'renders the forecast card' do
        expect(response.body).to include('3-Day Forecast')
        expect(response.body).to include('H: 61°')
        expect(response.body).to include('L: 51°')
      end
    end

    context 'with location param and error' do
      before do
        allow(WeatherFetcher).to receive(:call).with('bad').and_return(error: 'Oh no')
        get weather_path, params: { location: 'bad' }
      end

      it 'shows the error message' do
        expect(response.body).to include('Oh no')
      end
    end
  
  context 'with cached data', type: :request do
    # Reuse fake_weather definition from successful fetch context
    let(:fake_weather) do
      {
        place_name: 'Test City, TS, 12345',
        fetched_at: Time.current,
        cached: false,
        provider: 'TestProvider',
        current: { temp: 60, high: 65, low: 55, summary: 'clear sky' },
        forecast: [ { date: Date.today, high: 61, low: 51, summary: 'sunny' } ],
        lat: 10.0,
        lon: 20.0
      }
    end
    let(:fake_weather_cached) { fake_weather.merge(cached: true) }
    before do
      allow(WeatherFetcher).to receive(:call).with('12345').and_return(fake_weather_cached)
      get weather_path, params: { location: '12345' }
    end

    it 'renders both fetched-at and expires-at tags, without live pill' do
      expect(response.body).to include('<span id="weather-fetched-at"')
      expect(response.body).to include('data-timestamp="')
      expect(response.body).to include('<span id="weather-expires-at"')
      expect(response.body).to include('data-expiration="')
      expect(response.body).not_to include('Live data')
    end
  end
  end
end