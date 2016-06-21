$:.unshift File.expand_path("..", Dir.pwd)
$:.unshift File.expand_path("../Models", Dir.pwd)
$:.unshift File.expand_path("../Controllers", Dir.pwd)

require "rubygems"
require "bundler/setup"
require "Logging"
require "json"
require "tag"
require "detectionController"


begin
	Models::Checkout.new
	prefix = "TAG"
	epc = "4144303030303031"
	reader = "Door"
	antenna = "1"
	timestamp = "1464955454".to_i
	tzoffset = "0".to_i
	data = [prefix, epc, reader, antenna, timestamp, tzoffset]
	tag = Tag.new(data)
	gpio = 15

	detectioncontrol = DetectionController.new(15)
	control = detectioncontrol.start

	detectioncontrol.tagsQueue.push(tag)

	control.join(10)

rescue Exception => e
	puts e.backtrace.inspect
	puts "Exception thrown: #{e.inspect}"

ensure
	
end




