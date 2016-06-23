#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"..","Models")

require "rubygems"
require "thread"
require "json"
require "mqtt"
#require "checkout"
require "session"


class MqttController
	include Logging

	@@checkoutModel = Models::Checkout.new

	def initialize(server, port=1883, topic)
		@server = server
		@port = port
		@topic = topic
		@client_id = 'zing_pi_door'
		@client = nil
		@pub = MqttPublisher.new(server, "/queue/zing/snipeit")
		
	end

	def start
		Thread.new {self.subscribe}
	end

	def subscribe
		begin
			logger.debug {"MqttController starts a thread #{Thread.current.inspect}"}

			@client = MQTT::Client.connect(
				:host => @server, 
				:port => @port,
				:client_id => @client_id,
				:clean_session => false
			)
			logger.debug {"MqttController restores the session #{@client_id}"}


			@client.subscribe(@topic => 1)

			# MQTT connected, Retrieve all of checkout items
			retrieveCheckoutList = {"action" => "CheckoutList"}
			@pub.publish(retrieveCheckoutList)


			@client.get(@topic) do |topic, message|
				handleMessage(topic, message)
				logger.debug {"#{@topic} left #{@client.queue_length} messages"}
			end

		rescue SystemExit, Interrupt, MQTT::Exception, SystemCallError => e
			logger.debug {"Exception thrown: #{e.inspect}"}
			logger.info {"Re-Connect MQTT in 20s"}
			sleep(20)
			start
		ensure
			if @client
				@client.disconnect()
				logger.debug {"MqttController #{@client.object_id} disconnect"} 
			end
		end
	end


	def handleMessage(topic, message)
		begin
			msg = JSON.parse(message)
			logger.debug {"#{msg.inspect}"}

			if msg["CheckoutList"].nil? && msg["action"]
				@@checkoutModel.send(msg["action"], msg["data"])

			elsif msg["CheckoutList"]
				@@checkoutModel.send("deleteAll")

				msg["CheckoutList"].each do |item|
					@@checkoutModel.send(item["action"], item["data"])
				end
			else
				logger.debug {"Wrong Message Format"}
			end

		rescue JSON::ParserError => e
			logger.debug {"MqttController ParserError: #{e} from #{topic}"}

		rescue SQLite3::Exception => e
			logger.debug {"Exception thrown: #{e.inspect}"}
		end
	end
end


