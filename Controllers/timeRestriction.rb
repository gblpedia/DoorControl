require "./Logging"

class TimeRestriction
	include Logging
	
	def initialize(range)
		@outOfService = false

		if range == '-'
			@outOfService = true
		end
		timeslot = range.split('-')
		@startTime = timeslot[0].to_i
		@endTime = timeslot[1].to_i
		
		#puts "Range from #{@startTime} to #{@endTime}"
	end

	def isAllowed
		allow = false

		if @outOfService
			return allow
		else
			now = Time.new.localtime("+08:00")
			
			logger.debug { "Current Hour #{now.hour} UTC? #{now.utc?}" }
			if now.hour < @endTime && now.hour >= @startTime
				allow = true
				return allow
			else
				return allow
			end
		end
	end
end