module TheHub

  SESSIONS = {
    friday: [ '8:00 AM', '10:00 AM', '11:00 AM', '11:10 AM', '11:55 AM', '1:10 PM',
              '1:55 PM', '2:05 PM', '2:50 PM', '3:00 PM', '3:45 PM', '4:15 PM',
              '5:00 PM', '5:10 PM', '6:00PM', '7:00 PM', '9:00 PM'
            ],
    saturday: [ '8:00 AM', '10:00 AM', '10:45 AM', '10:55 AM', '11:40 AM', '12:55 PM',
                '1:40 PM', '1:50 PM', '2:35 PM', '2:45 PM', '3:30 PM', '4:00 PM',
                '4:45 PM', '4:55 PM', '7:00 PM', '9:00 PM'
            ]
  }

  BREAKOUTS = {
    friday: {'8:00 AM' => 'Registration',
             '11:00 AM' => 'Break',
             '11:55 AM' => 'Lunch',
             '1:55 PM' => 'Break',
             '2:50 PM' => 'Break',
             '3:45 PM' => 'Break',
             '5:00 PM' => 'Break'
            }
  }

  KEYNOTES = {
  }

  ROOMS = ['Salon 1', 'Salon 2', 'Poinciana']


  class Planner
    def initialize days, sitemap
      @days, @sitemap = days, sitemap
    end

    def days
      @days.map {|day| Day.new day, @sitemap}
    end
  end

  module Helpers
    def planner
      Planner.new days, sitemap
    end

  end

  class Day
    attr_reader :name
    def initialize name, sitemap
      @name, @sitemap = name, sitemap
    end

    def shortname
      name[0..2]
    end

    def code
      @name.downcase
    end

    def active?
      @name == 'Friday'
    end

    def query
      @sitemap.where(:day => @name)
    end

    def sessions
      if TheHub::SESSIONS[name.downcase.to_sym]
        TheHub::SESSIONS[name.downcase.to_sym].map do |time|
         Session.new time, name.downcase.to_sym, query
        end
      else
        []
      end
    end
  end

  class Session
    attr_accessor :time
    def initialize time, day, query
      @time, @day, @query = time, day, query
    end

    def talks_by_room room
      talks.detect {|t| t.room == room}
    end

    def sorted_talks
      TheHub::ROOMS.map {|r| talks_by_room r}.compact
    end

    def talks
      @query.where(:type => 'talk', :session => @time).all.map {|t| Talk.new t}
    end

    def breakout
      TheHub::BREAKOUTS.fetch(@day, {})[@time]
    end
  end

  class Talk
    def initialize resource
      @resource = resource
    end

    def data
      @resource.data
    end

    def room
      data.room
    end
  end
end

