#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"..","Models")

require "thread"
require 'rubygems'
require 'mqtt'
require 'json'

class MqttPublisher
	include Logging

	def initialize (host, topic)
		@host = host
		@topic = topic
		@client = nil
	end

	def publish(msg)
		begin
			MQTT::Client.connect(@host, 1883) do |c|
		        @client = c

		        timestamp = Time.new.localtime("+08:00").strftime("%Y%m%d%H%M%S")

		        msg["timestamp"] = timestamp

		        c.publish(@topic, msg.to_json)
		        logger.debug {"Publish #{msg.inspect} on #{@topic}"}
		    end
		
		rescue SystemExit, Interrupt, MQTT::Exception, SystemCallError => e
			logger.debug {"Publisher Exception thrown: #{e.inspect}"}

		ensure
			@client.disconnect() if @client
		end

	end

end
