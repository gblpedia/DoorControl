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
		@sessionModel = Models::Session.new
		@client_id = @sessionModel.getClientId(topic)
		@client = nil
		
	end

	def start
		Thread.new {self.subscribe}
	end

	def subscribe
		begin
			logger.debug {"MqttController starts a thread"}

			if @client_id.nil?
				@client = MQTT::Client.connect(
					:host => @server, 
					:port => @port,
				)
				@client_id = @client.client_id
				@sessionModel.create(@topic, @client_id)
				logger.debug {"MqttController starts a new session #{@client_id}"}
			else 
				@client = MQTT::Client.connect(
					:host => @server, 
					:port => @port,
					:client_id => @client_id,
					:clean_session => false
				)
				logger.debug {"MqttController restores the session #{@client_id}"}
			end

			@client.subscribe(@topic => 1)

			@client.get(@topic) do |topic, message|
				handleMessage(topic, message)
			end

		rescue SystemExit, Interrupt => e
			logger.debug {"Interrupt: #{e.inspect}"}

		rescue MQTT::Exception => e
			logger.debug {"Exception thrown: #{e.inspect}"}

		ensure
			logger.debug {"MqttController disconnect"}
			@client.disconnect()
		end
	end


	def handleMessage(topic, message)
		begin
			msg = JSON.parse(message)
			logger.debug {"#{msg.inspect}"}

			if msg["CheckoutList"].nil?
				@@checkoutModel.send(msg["action"], msg["data"])

			else 
				@@checkoutModel.send("deleteAll")

				msg["CheckoutList"].each do |item|
					@@checkoutModel.send(item["action"], item["data"])
				end
			end

		rescue JSON::ParserError => e
			logger.debug {"MqttController ParseError: #{e} from #{topic}"}

		rescue SQLite3::Exception => e
			logger.debug {"Exception thrown: #{e.inspect}"}
		end
	end
end


