# WeatherOnRails
[![Test Coverage](https://api.codeclimate.com/v1/badges/fbeb238cae8197ea34a1/test_coverage)](https://codeclimate.com/github/rmulligan/weather-on-rails/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/fbeb238cae8197ea34a1/maintainability)](https://codeclimate.com/github/rmulligan/weather-on-rails/maintainability)

WeatherOnRails is a Ruby on Rails application that lets users input a US address or ZIP code
to retrieve current weather and a 3-day forecast. It features:
  - Geocoding via Geocoder
  - Weather API providers: OpenWeatherMap and VisualCrossing (automatic fallback)
  - Low-level caching with expiration and cache indicator
  - Daily API request tracking and conservation mode when nearing rate limits
  - Docker support for easy setup

## Requirements
- Ruby 2.7.6
- Rails 6.0.6.1
- Node.js (>= 14)
- Yarn (for asset building)
- Memcached (using Dalli) for low-level caching
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
3. Configure API credentials (recommended):
   You may configure one or both API keys. If only one key is provided, only that provider will be used. When both are set, OpenWeatherMap is used first, falling back to VisualCrossing on errors.
   ```bash
   EDITOR="vim" rails credentials:edit
   ```
   Add at the top level:
   ```yaml
   openweathermap_api_key: YOUR_OPENWEATHERMAP_API_KEY  # optional
   visualcrossing_api_key: YOUR_VISUALCROSSING_API_KEY  # optional
   ```
   Or set environment variables instead:
   ```bash
   export OPENWEATHERMAP_API_KEY=YOUR_OPENWEATHERMAP_API_KEY
   export VISUALCROSSING_API_KEY=YOUR_VISUALCROSSING_API_KEY
   ```

## Local Development
Use the included `bin/dev` script to run Rails with asset watchers:
```bash
./bin/dev
```  
Then visit http://localhost:3000

## Docker (Optional)
Build and run the app in a container using the included Dockerfile:
```bash
# Build image (installs gems)
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

## Docker Compose (Optional)
Alternatively, use Docker Compose to build the image and start the server in one step:
```bash
# Ensure API keys are available in your environment
export OPENWEATHERMAP_API_KEY=YOUR_KEY
export VISUALCROSSING_API_KEY=YOUR_KEY

docker-compose up --build
```
This will:
- Mount your application code into the container for live reloading during development
- Persist gem dependencies in a named Docker volume for faster rebuilds. Automatically launch the Rails server
Visit http://localhost:3000 once services are up.

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
