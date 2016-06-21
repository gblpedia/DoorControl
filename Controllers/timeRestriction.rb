

class TimeRestriction
	include Logging
	
	def initialize(range)
		@outOfService = false

		unless range.nil?

			if range == '00:00-00:00'
				@outOfService = true
			end
			timeslot = range.split('-')
			@startTime = timeslot[0]
			@endTime = timeslot[1]
		end
	end

	def isAllowed
		allow = false

		if @outOfService
			logger.debug { "Out of Business Hour" }
			return allow
		else
			now = Time.new.localtime("+08:00")
			@start = parse( @startTime )
			@end = parse( @endTime)

			logger.debug { "Current Hour #{now.hour}, Is UTC Time? #{now.utc?}" }
			logger.debug { "Now #{now.inspect} \n start #{@start.inspect} \n end #{@end.inspect}" }

			if  @start <= now && now < @end
				allow = true
				return allow
			else
				return allow
			end

		end

	end

	def parse(hhmm)
		hour = hhmm.split(':')[0].to_i
		min = hhmm.split(':')[1].to_i
		sec = 0

		now = Time.new.localtime("+08:00")
		time = Time.new(now.year, now.mon, now.mday, hour, min, sec, "+08:00")
		return time
	end
end