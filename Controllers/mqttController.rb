#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"..","Models")

require "json"
require "rubygems"
require "mqtt"
require "checkout"
require "thread"


class MqttController
	include Logging

	@@checkoutModel = Models::Checkout.new

	def initialize(server, port=1883, topic)
		@server = server
		@port = port
		@topic = topic
	end

	def start
		Thread.new {self.subscribe}
	end

	def subscribe
		begin
			logger.debug {"MqttController starts a thread"}
			client = MQTT::Client.connect(@server, @port) do |c|
				c.get(@topic) do |topic, message|
					handleMessage(topic, message)
				end
			end

		rescue MQTT::Exception => e
			logger.debug {"Exception thrown: #{e.inspect}"}

		ensure
			client.disconnect()
		end
	end


	def handleMessage(topic, message)
		begin
			msg = JSON.parse(message)
			logger.debug {"#{msg.inspect}"}
			@@checkoutModel.send(msg["action"], msg["data"])

		rescue JSON::ParserError => e
			logger.debug {"MqttController ParseError: #{e} from #{topic}"}

		rescue SQLite3::Exception => e
				logger.debug {"Exception thrown: #{e.inspect}"}
		end
	end
end


