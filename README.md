# Exporter Plugin for Redmine 6.x (forked from original @noshutdown-ru/redexporter)

A modern Redmine plugin that exports system and application metrics to Prometheus for monitoring and alerting.

## Features

- **System Metrics**: CPU usage, memory usage, disk space, load average
- **Redmine Metrics**: Users, sessions, issues, projects, file storage
- **Secure Authentication**: Token-based authentication for metrics endpoint
- **Easy Configuration**: Simple admin interface for plugin settings
- **Prometheus Compatible**: Outputs metrics in Prometheus text format
- **Rails 6+ Compatible**: Built with Zeitwerk autoloader support
- **Error Handling**: Robust error handling with detailed logging

## Requirements

- Redmine 6.x or higher
- Ruby 3.0 or higher
- Prometheus server for scraping metrics

## Installation

### 1. Install the plugin

```bash
cd /path/to/redmine/plugins
git clone https://github.com/chaunt1/redexporter
```

### 2. Install dependencies

```ruby
gem 'vmstat', '~> 2.3'
gem 'prometheus_exporter', '~> 2.0'
```

Then run:

```bash
cd /path/to/redmine
bundle install
```

### 3. Configure the plugin

1. Log in as an administrator
2. Navigate to **Administration → Exporter**
3. Enable metrics export
4. Copy the authentication token (or generate a new one)
5. Copy the Prometheus configuration example

## Configuration

### Plugin Settings

Navigate to **Administration → Exporter** to configure:

- **Enable Metrics Export**: Turn metrics export on/off
- **Authentication Token**: Secure token for Prometheus scraper
- **Metrics URL**: Endpoint URL for Prometheus to scrape

### Prometheus Configuration

Add this configuration to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'redmine'
    scrape_interval: 60s
    scrape_timeout: 30s
    scheme: 'https'  # or 'http'
    metrics_path: '/exporter/metrics'
    params:
      token: ['YOUR_TOKEN_HERE']
    static_configs:
      - targets: ['your-redmine-host.com']
        labels:
          instance: 'redmine-production'
          environment: 'production'
```

Replace:
- `YOUR_TOKEN_HERE` with your actual token from plugin settings
- `your-redmine-host.com` with your Redmine hostname
- `https` with `http` if not using SSL

## Available Metrics

### System Metrics

| Metric Name | Type | Description |
|------------|------|-------------|
| `load_average_one_minute` | Gauge | System load average (1 minute) |
| `disk_total_bytes` | Gauge | Total disk space in bytes |
| `disk_used_bytes` | Gauge | Used disk space in bytes |
| `disk_free_bytes` | Gauge | Free disk space in bytes |
| `cpu_usage_percent` | Gauge | CPU usage percentage |
| `memory_total_bytes` | Gauge | Total system memory in bytes |
| `memory_free_bytes` | Gauge | Free system memory in bytes |
| `memory_used_bytes` | Gauge | Used system memory in bytes |

### Redmine Metrics

| Metric Name | Type | Description |
|------------|------|-------------|
| `redmine_user_count` | Gauge | Number of active users |
| `redmine_active_sessions_count` | Gauge | Active sessions (last 5 minutes) |
| `redmine_files_size_bytes` | Gauge | Total size of files directory |
| `redmine_issues_count` | Gauge | Total number of issues |
| `redmine_issues_open` | Gauge | Number of open issues |
| `redmine_issues_closed` | Gauge | Number of closed issues |
| `redmine_projects_active_count` | Gauge | Number of active projects |
| `redmine_projects_count` | Gauge | Total number of projects |

## Security

### Authentication

The metrics endpoint requires token authentication. The token should be:
- Kept secret and not committed to version control
- Regularly rotated (use "Regenerate Token" button)
- Transmitted only over HTTPS in production

### Access Control

- Metrics endpoint is accessible without login (token-based auth)
- Settings page requires administrator privileges
- Failed authentication attempts are logged

## Troubleshooting

### Metrics endpoint returns 403 error

- Check that metrics export is enabled in plugin settings
- Verify the authentication token matches your Prometheus configuration
- Check Redmine logs for detailed error messages

### Metrics show zero values

- Check Redmine logs for error messages
- Verify that vmstat gem is properly installed
- Ensure Redmine has permissions to read system information

### Token regeneration doesn't work

- Check that JavaScript is enabled in your browser
- Verify CSRF token is present in the page
- Check browser console for JavaScript errors

## Development

### File Structure

```
exporter/
├── app/
│   ├── controllers/
│   │   ├── exporter_controller.rb
│   │   └── exporter_settings_controller.rb
│   ├── helpers/
│   │   └── exporter_helper.rb
│   └── views/
│       ├── exporter_settings/
│       │   └── index.html.erb
│       └── settings/
│           └── _exporter_settings.html.erb
├── config/
│   ├── locales/
│   │   ├── en.yml
│   │   └── vi.yml
│   └── routes.rb
├── lib/
│   ├── exporter.rb
│   └── exporter/
│       ├── redmine.rb
│       └── vmstat.rb
├── Gemfile
├── init.rb
└── README.md
```

### Zeitwerk Naming Conventions

This plugin follows Rails 6+ Zeitwerk autoloading conventions:

- `lib/exporter.rb` → `Exporter`
- `lib/exporter/vmstat.rb` → `Exporter::Vmstat`
- `lib/exporter/redmine.rb` → `Exporter::Redmine`

No manual `require` statements needed - Zeitwerk handles autoloading.

### Adding New Metrics

1. Add metric collection method to appropriate module:
   - System metrics: `lib/exporter/vmstat.rb`
   - Redmine metrics: `lib/exporter/redmine.rb`

2. Use the helper methods from `BaseCollector`:
   ```ruby
   def self.my_new_metric
     metric = PrometheusExporter::Metric::Gauge.new(
       'metric_name',
       'Metric description'
     )
     
     value = safe_collect { # your collection logic }
     metric.observe(value)
     to_prometheus_text(metric)
   end
   ```

3. Add the metric to controller's `collect_all_metrics` method

4. Add translations to locale files

5. Update README documentation

## Testing

### Manual Testing

1. Enable the plugin and generate a token
2. Access metrics endpoint:
   ```bash
   curl "http://your-redmine-host/exporter/metrics?token=YOUR_TOKEN"
   ```

3. Verify metrics output format

### Prometheus Testing

1. Configure Prometheus as shown above
2. Check Prometheus targets page for scrape status
3. Query metrics in Prometheus:
   ```promql
   redmine_issues_total
   cpu_usage_percent
   ```

## License

This plugin is released under the MIT License.

## Credits

- Original inspiration from [redexporter](https://github.com/noshutdown/redmine-plugins-redexporter) plugin
- Rebuilt for Redmine 6.x with modern Rails conventions
- Developed by chaunt

## Support

- **Issues**: https://github.com/chaunt1/exporter/issues

## Changelog

### Version 1.0.0 (2025-10-28)

- Initial release for Redmine 6.x
- Zeitwerk autoloader support
- Rails 6+ compatibility
- Token-based authentication
- System and Redmine metrics
- Bilingual support (English & Vietnamese)
- Modern admin interface with AJAX token regeneration

