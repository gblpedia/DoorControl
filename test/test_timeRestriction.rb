#Add the default relative library location to the search path

$:.unshift File.expand_path("..", Dir.pwd)
$:.unshift File.expand_path("../Models", Dir.pwd)
$:.unshift File.expand_path("../Controllers", Dir.pwd)

require "json"
require "Logging"
require "timeRestriction"




begin
	
	period = "00:00-20:00"
	control = TimeRestriction.new(period)
	if control.isAllowed
		puts "Access Allowed"

	else
		puts "Access Denied"
	end


rescue Exception => e
	puts e.backtrace.inspect
	puts "Exception thrown: #{e.inspect}"

ensure
	
end


