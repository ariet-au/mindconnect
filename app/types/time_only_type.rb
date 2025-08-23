# app/types/time_only_type.rb
class TimeOnlyType < ActiveRecord::Type::Value
  DUMMY_DATE = [2000, 1, 1].freeze

  def cast(value)
    return if value.blank?

    case value
    when String
      parse_string(value)
    when Time
      Time.utc(*DUMMY_DATE, value.hour, value.min, value.sec)
    else
      nil
    end
  end

  def serialize(value)
    return if value.blank?
    value.strftime("%H:%M:%S")
  end

  def deserialize(value)
    return if value.blank?

    case value
    when String
        parse_string(value)
    when Time
        Time.utc(*DUMMY_DATE, value.hour, value.min, value.sec)
    else
        nil
    end
    end

  private

  def parse_string(value)
    t = Time.strptime(value, value.include?(":") && value.count(":") == 2 ? "%H:%M:%S" : "%H:%M")
    Time.utc(*DUMMY_DATE, t.hour, t.min, t.sec)
  rescue ArgumentError
    nil
  end
end
