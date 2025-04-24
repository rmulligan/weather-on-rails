# WeatherOnRails

WeatherOnRails is a Ruby on Rails application that lets users input a US address or ZIP code
to retrieve current weather and a 3-day forecast. It features:
  - Geocoding via Geocoder
  - Primary weather API: OpenWeatherMap
  - Secondary API fallback: Visual Crossing
  - Low-level caching with expiration and cache indicator
  - UI toggle for selecting the API provider
  - Daily API request tracking and conservation mode when nearing rate limits
  - Docker support for easy setup

## Requirements
- Ruby 2.7.6
- Rails 6.0.6.1
- SQLite3
- Node.js (>= 14)
- Yarn (for asset building)
- Docker & Docker Compose (optional, for containerized setup)

## Configuration
1. Clone the repository:
   ```bash
   git clone https://github.com/rmulligan/weather-on-rails.git
   cd weather-on-rails
   ```
2. Install gems:
   ```bash
   bundle install
   ```
3. Configure API credentials:
   ```bash
   EDITOR="vim" rails credentials:edit
   ```
   Add:
   ```yaml
   openweathermap_api_key: YOUR_OPENWEATHERMAP_API_KEY
   visualcrossing_api_key: YOUR_VISUALCROSSING_API_KEY
   ```
4. Database setup:
   ```bash
   rails db:create db:migrate
   ```

## Local Development
Use the included `bin/dev` script to run Rails with asset watchers:
```bash
./bin/dev
```  
Then visit http://localhost:3000

## Docker (Optional)
Build and run the app in a container:
```bash
# Build image
docker build -t weather-on-rails .
# Run container
docker run -d \
  -p 3000:3000 \
  -e OPENWEATHERMAP_API_KEY=$OPENWEATHERMAP_API_KEY \
  -e VISUALCROSSING_API_KEY=$VISUALCROSSING_API_KEY \
  --name weather-app \
  weather-on-rails
```  
Then visit http://localhost:3000

## Configuration Settings
- `config.x.weather.cache_expiration` (in seconds, default 1800) controls cache TTL
- `config.x.weather.rate_limit.openweathermap` (daily limit, default 1000)
- `config.x.weather.rate_limit.visualcrossing` (daily limit, default 1000)

## Testing
Run the full test suite with:
```bash
bundle exec rspec
```  
Key specs:
  - `spec/services/weather_fetcher_cache_spec.rb` (cache indicator)
  - `spec/services/weather_fetcher_rate_limiting_spec.rb` (rate-limiting logic)

## Contributing
Pull requests welcome! Please include tests and update documentation as needed.
