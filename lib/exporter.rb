# frozen_string_literal: true

require 'prometheus_exporter/metric'

# Main module for Exporter plugin
# Provides Prometheus metrics for Redmine monitoring
# 
# This module follows Zeitwerk naming conventions for Rails 6+
# File: lib/exporter.rb -> Module: Exporter
module Exporter
  class Error < StandardError; end
  
  # Base module for all metrics collectors
  # Provides helper methods for safe metric collection and formatting
  module BaseCollector
    # Safely execute a block and return a metric value
    # Returns 0 if an error occurs
    def safe_collect
      yield
    rescue StandardError => e
      Rails.logger.error "Exporter: #{e.class} - #{e.message}"
      0
    end

    # Generate Prometheus text format for a metric
    def to_prometheus_text(metric)
      metric.to_prometheus_text
    rescue StandardError => e
      Rails.logger.error "Exporter: Failed to generate Prometheus text - #{e.message}"
      ""
    end
  end
end

