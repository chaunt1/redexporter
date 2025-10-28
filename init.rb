# frozen_string_literal: true

# Exporter Plugin for Redmine 6.x
# Compatible with Zeitwerk autoloader (Rails 6+)

Redmine::Plugin.register :exporter do
  name 'Exporter Plugin'
  author 'chaunt1'
  description 'Exposes Redmine metrics to Prometheus for monitoring (Redmine 6.x compatible)'
  version '1.0.0'
  url 'https://github.com/chaunt1/redexporter'
  author_url 'https://chaunt.dev'

  # Plugin settings with default values
  settings default: {
    'exporter_enabled' => false,
    'exporter_prometheus_token' => SecureRandom.hex(16)
  }, partial: 'settings/exporter_settings'

  # Add menu item in admin menu
  menu :admin_menu, :exporter, 
    { controller: 'exporter_settings', action: 'index' },
    caption: :exporter_label,
    html: { class: 'icon icon-stats' }
end
