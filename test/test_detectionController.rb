$:.unshift File.expand_path("..", Dir.pwd)
$:.unshift File.expand_path("../Models", Dir.pwd)
$:.unshift File.expand_path("../Controllers", Dir.pwd)

require "Logging"
require "json"
require "tag"
require "detectionController"


begin
	Models::Checkout.new
	prefix = "TAG"
	epc = "AD000002"
	reader = "Door"
	antenna = "1"
	timestamp = "1464955454".to_i
	tzoffset = "0".to_i
	data = [prefix, epc, reader, antenna, timestamp, tzoffset]
	tag = Tag.new(data)
	gpio = 14

	detectioncontrol = DetectionController.new(14)
	control = detectioncontrol.start

	detectioncontrol.tagsQueue.push(tag)

	control.join(3)

rescue Exception => e
	puts e.backtrace.inspect
	puts "Exception thrown: #{e.inspect}"

ensure
	
end


