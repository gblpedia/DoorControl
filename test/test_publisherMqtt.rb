#Add the default relative library location to the search path
$: << File.join(File.expand_path("../", File.dirname(__FILE__)))
$: << File.join(File.expand_path("../Models/", File.dirname(__FILE__)))
$: << File.join(File.expand_path("../Controllers/", File.dirname(__FILE__)))


require "Logging"
require "json"
require "publisherMqtt"


begin
	host = "localhost"
	topic = "/queue/zing/snipeit"
	pub = MqttPublisher.new(host, topic)

	message = "{\"event\":\"Access\", \"model\":\"UHF ISO CARD\", \"epc\":\"41443030303120202020202020202020\", \"location\":\"Door\"}"
	json = JSON.parse(message)

	pub.publish(json)
	
rescue Exception => e
	puts e.backtrace.inspect
	puts "Exception thrown: #{e.inspect}"

ensure
	
end


