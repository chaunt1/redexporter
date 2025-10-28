# frozen_string_literal: true

# Redmine-specific metrics collector
# Collects metrics about users, issues, projects, and files
module Exporter
  module Redmine
    extend BaseCollector

    class << self
      # Count total users (excluding anonymous)
      def user_count
        metric = PrometheusExporter::Metric::Gauge.new(
          'redmine_user_count',
          'Number of users in Redmine (excluding anonymous)'
        )
        
        value = safe_collect { User.active.count }
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Count active sessions (users logged in within last 5 minutes)
      def sessions_count
        metric = PrometheusExporter::Metric::Gauge.new(
          'redmine_active_sessions_count',
          'Number of active user sessions in Redmine'
        )
        
        value = safe_collect do
          User.active.where('last_login_on >= ?', 5.minutes.ago).count
        end
        
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Calculate total size of Redmine files directory
      def files_size_bytes
        metric = PrometheusExporter::Metric::Gauge.new(
          'redmine_files_size_bytes',
          'Total size of Redmine files directory in bytes'
        )
        
        value = safe_collect do
          files_path = Rails.root.join('files')
          return 0 unless File.directory?(files_path)
          
          total_size = 0
          Dir.glob(files_path.join('**', '*')).each do |file|
            total_size += File.size(file) if File.file?(file)
          end
          total_size
        end
        
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Count all issues
      def all_issues_count
        metric = PrometheusExporter::Metric::Gauge.new(
          'redmine_issues_count',
          'Total number of issues in Redmine'
        )
        
        value = safe_collect { Issue.count }
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Count open issues
      def open_issues_count
        metric = PrometheusExporter::Metric::Gauge.new(
          'redmine_issues_open',
          'Number of open issues in Redmine'
        )
        
        value = safe_collect do
          Issue.joins(:status).where(issue_statuses: { is_closed: false }).count
        end
        
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Count closed issues
      def closed_issues_count
        metric = PrometheusExporter::Metric::Gauge.new(
          'redmine_issues_closed',
          'Number of closed issues in Redmine'
        )
        
        value = safe_collect do
          Issue.joins(:status).where(issue_statuses: { is_closed: true }).count
        end
        
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Count active projects
      def active_projects_count
        metric = PrometheusExporter::Metric::Gauge.new(
          'redmine_projects_active_count',
          'Number of active projects in Redmine'
        )
        
        value = safe_collect { Project.active.count }
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Count total projects
      def total_projects_count
        metric = PrometheusExporter::Metric::Gauge.new(
          'redmine_projects_count',
          'Total number of projects in Redmine'
        )
        
        value = safe_collect { Project.count }
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Collect all Redmine metrics at once
      def all_metrics
        [
          user_count,
          sessions_count,
          files_size_bytes,
          all_issues_count,
          open_issues_count,
          closed_issues_count,
          active_projects_count,
          total_projects_count
        ].join
      end
    end
  end
end

