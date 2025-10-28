# frozen_string_literal: true

# Routes for Exporter plugin
# Compatible with Rails 6+ routing conventions

# Metrics endpoint for Prometheus
get 'metrics', to: 'exporter#index', as: 'exporter_metrics'

# Settings routes
resources :exporter_settings, only: [:index] do
  collection do
    post :save
    post :regenerate_token
  end
end
