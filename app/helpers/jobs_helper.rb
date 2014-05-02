module JobsHelper
  def labelize(logs)
    logs.map do |log|
      # Timestamp
      timestamp = log.scan(/^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/).first

      if timestamp
        timestamp_parsed = Time.parse(timestamp + ' UTC').in_time_zone(Rails.application.config.time_zone)
        log.gsub!(/^#{timestamp}/, "<span style='color: grey;'>#{timestamp_parsed.to_s(:job_log)}</span>")
      end

      # Log level
      log_level = log.scan(/\[DEBUG\]|\[INFO\]|\[WARN\]|\[ERROR\]|\[FATAL\]/).first
      log.gsub!(log_level, "<span class='label label-#{log_label_color(log_level.scan(/\w+/).first.downcase)} job-log-label'>#{log_level.tr('[','').tr(']', '')}</span>") if log_level

      log
    end
  end

  private

  def log_label_color(level)
    case level
      when 'debug' then
        'info'
      when 'info' then
        'primary'
      when 'warn' then
        'warning'
      when 'error' then
        'danger'
      else
        'default'
    end
  end
end
