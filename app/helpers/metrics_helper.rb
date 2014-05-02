module MetricsHelper
  def humanize(secs)
    return nil if secs == 0
    return '< 1m' if secs < 60

    # Round it up to the nearest minute.
    mins = (secs + 30 - (secs + 30) % 60) / 60

    [[60, :m], [24, :h], [365, :d], [1000, :y]].map{ |count, name|
      if mins > 0
        mins, n = mins.divmod(count)
        "#{n.to_i}#{name}" if n != 0
      end
    }.compact.reverse.join
  end

  def card_date(datetime)
    return '' if datetime.nil?
    datetime.in_time_zone('Kolkata').to_s(:card)
  end
end
