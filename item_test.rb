#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__))
$: << File.join(File.dirname(__FILE__),"/","Models")
$: << File.join(File.dirname(__FILE__),"/","Controllers")

require "Logging"
require "sqlite3"
require "json"
require "checkout"
#require "MqttController"


begin
	model = Models::Checkout.new

rescue Exception => e
	puts e.inspect

ensure
	model.close
end

#sub = MQTTController::Subscriber.new
