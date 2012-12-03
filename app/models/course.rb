module Konosys
  module Models
    class Course
      attr_reader :date, :length, :code, :name, :room, :group, :type, :teacher

      def initialize(date, details)
        # Todo: Update date!
        day = details[0]
        hour = details[1]
        minutes = details[2]
        course_date = date + (day.to_i - 1)
        @date = Time.mktime(course_date.year, course_date.month, course_date.day, hour.to_i, minutes.to_i)
        @length = details[3]

        details = details[4].gsub(/#{Regexp.escape('\\')}/, '').split('<br>')
        if details.count >= 4
          sub_details = details[0].split('-')
          @code = sub_details[0][0..-2]
          @name = sub_details[1][1..-1]
          @room = details[1][6..-1]
          @group = details[2][7..-2]
          @type = details[3]
          @teacher = details[4] if details.count == 5
        else
          @name = details.join ' '
        end
      end

      class Entity < Grape::Entity
        expose :date, :length, :type, :group, :code, :name, :room, :teacher
      end
    end
  end
end