require "thread"
require "checkout"
require "publisherMqtt"

class DoorController
	include Logging

	attr_reader :tagsQueue

	def initialize(gpioDoor)
		@location = "Door"
		@gpioDoor = gpioDoor;
		@tagsQueue = Queue.new
		logger.debug { "init #{self.class.name}" }
	end

	def process
		logger.debug { "DoorController Starts a thread" }

		while tag = @tagsQueue.pop
			logger.debug { "DoorController Pops a tag \n#{tag.epc}" }

			# Need to put in configuration
			pub = MqttPublisher.new("192.168.1.63", "/queue/zing/snipeit")
			msg = Hash.new

			if Models::Checkout.items.has_key?(tag.epc)
				# Deteted user card in checkout list
				item = Models::Checkout.items[tag.epc]
				
				if item.model == 'UHF ISO CARD' && item.isAllowed
					logger.debug {"Door Accessed"}

					msg["event"] = "Accessed"
					toggle(@gpioDoor)

				else
					logger.debug {"Door Access Denied due to Policy"}
					msg["event"] = "Denied"
				end

				msg["model"] = item.model
				msg["epc"] = item.epc
				msg["location"] = @location

			else
				# Detected user card is not in checkout list
				logger.debug {"Door Access Denied due to unknown tag"}
				
				msg["event"] = "Denied"
				msg["model"] = "Unknown"
				msg["epc"] = tag.epc
				msg["location"] = @location

			end

			pub.publish(msg)

		end
	end

	def start
		Thread.new {self.process}
	end

	def toggle(gpio)
		Thread.new {
			logger.debug {"toggle GPIO #{gpio} on"}
			sleep(2)
			logger.debug {"toggle GPIO #{gpio} off"}
		}
	end
end