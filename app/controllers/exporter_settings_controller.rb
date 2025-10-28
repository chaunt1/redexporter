# frozen_string_literal: true

# Settings controller for Exporter plugin
# Allows administrators to configure the plugin
class ExporterSettingsController < ApplicationController
  layout 'admin'
  
  # Rails 6+ style - before_action instead of before_filter
  before_action :require_admin
  
  # Set menu item for admin navigation
  menu_item :exporter

  # GET /exporter_settings
  # Display plugin settings page
  def index
    @settings = Setting.plugin_exporter || {}
    
    # Ensure token exists
    if @settings['exporter_prometheus_token'].blank?
      @settings['exporter_prometheus_token'] = generate_token
      Setting.plugin_exporter = @settings
    end
  end

  # POST /exporter_settings/save
  # Save plugin settings
  def save
    settings_params = params[:settings] || {}
    
    # Merge with existing settings
    current_settings = Setting.plugin_exporter || {}
    new_settings = current_settings.merge(settings_params.to_unsafe_h)
    
    # Save settings
    Setting.plugin_exporter = new_settings
    
    flash[:notice] = t('exporter.messages.settings_saved')
    redirect_to action: 'index'
  rescue StandardError => e
    Rails.logger.error "Exporter: Failed to save settings - #{e.class}: #{e.message}"
    flash[:error] = t('exporter.errors.save_failed')
    redirect_to action: 'index'
  end

  # POST /exporter_settings/regenerate_token
  # Generate a new authentication token
  def regenerate_token
    current_settings = Setting.plugin_exporter || {}
    current_settings['exporter_prometheus_token'] = generate_token
    Setting.plugin_exporter = current_settings
    
    render json: { 
      success: true, 
      token: current_settings['exporter_prometheus_token'],
      message: t('exporter.messages.token_regenerated')
    }
  rescue StandardError => e
    Rails.logger.error "Exporter: Failed to regenerate token - #{e.class}: #{e.message}"
    render json: { 
      success: false, 
      message: t('exporter.errors.token_generation_failed')
    }, status: :internal_server_error
  end

  private

  # Generate a secure random token
  def generate_token
    SecureRandom.hex(32)
  end
end

