#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__))
$: << File.join(File.dirname(__FILE__),"/","Models")
$: << File.join(File.dirname(__FILE__),"/","Controllers")

require "Logging"
require "json"
require "tag"
require "doorController"


begin
	Models::Checkout.new
	prefix = "TAG"
	epc = "400041443030303120202020202020202020"
	reader = "Door"
	antenna = "0"
	timestamp = "1464955454".to_i
	tzoffset = "0".to_i
	data = [prefix, epc, reader, antenna, timestamp, tzoffset]
	tag = Tag.new(data)
	gpio = 14

	doorcontrol = DoorController.new(14)
	control = doorcontrol.start

	doorcontrol.tagsQueue.push(tag)

	control.join(3)

rescue Exception => e
	puts e.backtrace.inspect
	puts "Exception thrown: #{e.inspect}"

ensure
	
end


