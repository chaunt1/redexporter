# frozen_string_literal: true

require 'vmstat'

# System metrics collector using vmstat
# Collects CPU, disk, and load average metrics
module Exporter
  module Vmstat
    extend BaseCollector

    class << self
      # Collect load average for the last minute
      def load_average_one_minute
        metric = PrometheusExporter::Metric::Gauge.new(
          'load_average_one_minute',
          'Current load average at the time when the snapshot took place'
        )
        
        value = safe_collect { ::Vmstat.snapshot.load_average.one_minute }
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Collect total disk space in bytes
      def disk_total_bytes
        metric = PrometheusExporter::Metric::Gauge.new(
          'disk_total_bytes',
          'Total bytes available on the file system'
        )
        
        value = safe_collect do
          disks = ::Vmstat.snapshot.disks
          disks.empty? ? 0 : disks.first.total_bytes
        end
        
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Collect used disk space in bytes
      def disk_used_bytes
        metric = PrometheusExporter::Metric::Gauge.new(
          'disk_used_bytes',
          'Used bytes on the file system'
        )
        
        value = safe_collect do
          disks = ::Vmstat.snapshot.disks
          disks.empty? ? 0 : disks.first.used_bytes
        end
        
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Collect free disk space in bytes
      def disk_free_bytes
        metric = PrometheusExporter::Metric::Gauge.new(
          'disk_free_bytes',
          'Free bytes on the file system'
        )
        
        value = safe_collect do
          disks = ::Vmstat.snapshot.disks
          disks.empty? ? 0 : disks.first.free_bytes
        end
        
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Collect CPU usage percentage
      # Note: This method sleeps for 1 second to calculate CPU usage
      def cpu_usage
        metric = PrometheusExporter::Metric::Gauge.new(
          'cpu_usage_percent',
          'CPU usage in percent'
        )
        
        value = safe_collect do
          cpus = ::Vmstat.snapshot.cpus
          return 0 if cpus.empty?
          
          cpu1 = cpus.first
          sleep 1
          cpu2 = ::Vmstat.snapshot.cpus.first

          # Calculate CPU time deltas
          total_time = (cpu2.idle - cpu1.idle) +
                      (cpu2.nice - cpu1.nice) +
                      (cpu2.system - cpu1.system) +
                      (cpu2.user - cpu1.user)

          idle_time = cpu2.idle - cpu1.idle
          usage_time = total_time - idle_time

          # Calculate percentage
          total_time.zero? ? 0 : (usage_time.to_f / total_time * 100).round(2)
        end
        
        metric.observe(value)
        to_prometheus_text(metric)
      end

      # Collect memory usage metrics
      def memory_usage
        metric_total = PrometheusExporter::Metric::Gauge.new(
          'memory_total_bytes',
          'Total system memory in bytes'
        )
        metric_free = PrometheusExporter::Metric::Gauge.new(
          'memory_free_bytes',
          'Free system memory in bytes'
        )
        metric_used = PrometheusExporter::Metric::Gauge.new(
          'memory_used_bytes',
          'Used system memory in bytes'
        )

        result = safe_collect do
          memory = ::Vmstat.snapshot.memory
          total = memory.total_bytes
          free = memory.free_bytes
          used = total - free
          
          metric_total.observe(total)
          metric_free.observe(free)
          metric_used.observe(used)
          
          to_prometheus_text(metric_total) +
          to_prometheus_text(metric_free) +
          to_prometheus_text(metric_used)
        end

        result || ""
      end
    end
  end
end

