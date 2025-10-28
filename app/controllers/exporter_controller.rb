# frozen_string_literal: true

# Main controller for Exporter metrics endpoint
# Handles Prometheus metrics requests with token authentication
class ExporterController < ApplicationController
  # Skip CSRF token verification for metrics endpoint (Prometheus scraper doesn't send it)
  skip_before_action :verify_authenticity_token, only: [:index]
  
  # Skip session requirement for API endpoint
  skip_before_action :check_if_login_required, only: [:index]

  # GET /metrics
  # Returns Prometheus metrics in text format
  def index
    # Check if plugin is enabled
    unless plugin_enabled?
      render_error_message(t('exporter.errors.disabled'))
      return
    end

    # Verify authentication token
    unless valid_token?
      render_error_message(t('exporter.errors.unauthorized'))
      return
    end

    # Collect all metrics
    metrics_data = collect_all_metrics
    
    # Return metrics in Prometheus text format
    render plain: metrics_data, content_type: 'text/plain; version=0.0.4'
  rescue StandardError => e
    Rails.logger.error "Exporter: Failed to generate metrics - #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render_error_message(t('exporter.errors.internal_error'))
  end

  private

  # Check if the plugin is enabled in settings
  def plugin_enabled?
    setting_value = Setting.plugin_exporter['exporter_enabled']
    # Handle both string and boolean values
    setting_value == true || setting_value == 'on' || setting_value == '1'
  end

  # Verify the authentication token from request params
  def valid_token?
    provided_token = params[:token]
    expected_token = Setting.plugin_exporter['exporter_prometheus_token']
    
    provided_token.present? && 
    expected_token.present? && 
    ActiveSupport::SecurityUtils.secure_compare(provided_token, expected_token)
  end

  # Collect all system and Redmine metrics
  def collect_all_metrics
    metrics = []

    # System metrics (vmstat)
    metrics << Exporter::Vmstat.load_average_one_minute
    metrics << Exporter::Vmstat.disk_total_bytes
    metrics << Exporter::Vmstat.disk_used_bytes
    metrics << Exporter::Vmstat.disk_free_bytes
    metrics << Exporter::Vmstat.cpu_usage
    metrics << Exporter::Vmstat.memory_usage

    # Redmine metrics
    metrics << Exporter::Redmine.all_metrics

    metrics.compact.join
  end

  # Render error message in plain text
  def render_error_message(message)
    render plain: "# ERROR: #{message}", status: :forbidden, content_type: 'text/plain'
  end
end

