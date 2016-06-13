#Add the default relative library location to the search path

$:.unshift File.expand_path("..", Dir.pwd)
$:.unshift File.expand_path("../Models", Dir.pwd)
$:.unshift File.expand_path("../Controllers", Dir.pwd)

require "json"
require "Logging"
require "tag"
require "doorController"




begin
	Models::Checkout.new
	prefix = "TAG"
	epc = "41443030303120202020202020202020"
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


