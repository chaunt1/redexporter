# frozen_string_literal: true

# Helper methods for Exporter views
module ExporterHelper
  # Format bytes to human readable format
  def format_bytes(bytes)
    return '0 B' if bytes.zero?
    
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = [exp, units.size - 1].min
    
    format('%.2f %s', bytes.to_f / (1024**exp), units[exp])
  end

  # Check if Exporter is enabled
  def exporter_enabled?
    setting = Setting.plugin_exporter['exporter_enabled']
    setting == true || setting == 'on' || setting == '1'
  end
end

