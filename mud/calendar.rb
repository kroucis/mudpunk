module MUD
  Month = Struct.new :name, :days, :lore

  class Chrono
    attr_accessor :year, :month, :day, :hour, :minute, :second, :real_time

    def self.from_h hash
      puts "Chrono#from_h #{hash[:real_time]}"
      self.new hash[:year], hash[:month], hash[:day], hash[:hour], hash[:minute], hash[:second], hash[:real_time]
    end

    def to_h
      { 
        year: @year, 
        month: @month,
        day: @day,
        hour: @hour,
        minute: @minute,
        second: @second,
        real_time: @real_time,
      }
    end

    def initialize year, month, day, hour, minute, second, real_time
      puts "real time: #{real_time}"
      @year = year
      @month = month
      @hour = hour
      @day = day
      @minute = minute
      @second = second
      @real_time = real_time
    end

  end

  class Calendar
    attr_accessor :months

    def initialize yaml_blob
      @months = [ ]
      yaml_blob.each do |name, month|
        @months << Month.new(name, month['days'], month['lore'])
      end
    end

    def num_days_in_year
      sum = 0
      @months.each do |name, month|
        sum += month.days
      end
      sum
    end

  end

end
