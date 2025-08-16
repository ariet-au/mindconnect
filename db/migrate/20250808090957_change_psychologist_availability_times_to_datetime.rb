class ChangePsychologistAvailabilityTimesToDatetime < ActiveRecord::Migration[8.0]
  def up  
    execute <<-SQL
      ALTER TABLE psychologist_availabilities
      ALTER COLUMN start_time_of_day TYPE timestamp without time zone
      USING ('2000-01-01 ' || start_time_of_day)::timestamp;
    SQL

    execute <<-SQL
      ALTER TABLE psychologist_availabilities
      ALTER COLUMN end_time_of_day TYPE timestamp without time zone
      USING ('2000-01-01 ' || end_time_of_day)::timestamp;
    SQL
  end

  def down
    change_column :psychologist_availabilities, :start_time_of_day, :time
    change_column :psychologist_availabilities, :end_time_of_day, :time
  end
end