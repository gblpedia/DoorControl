require "thread"
require "checkout"
require "publisherMqtt"

class DetectionController
	include Logging

	attr_reader :tagsQueue
	
	def initialize(gpio)
		@location = "Door"
		@gpioAlarm = gpio;
		@tagsQueue = Queue.new
		logger.debug { "init #{self.class.name}" }
	end

	def process
		logger.debug { "DetectionController Starts a thread" }

		while tag = @tagsQueue.pop
			logger.debug { "DetectionController Pops a tag \n#{tag.epc}" }

			if tag.epc.start_with?("AD")
				# Need to put in configuration
				pub = MqttPublisher.new("192.168.1.63", "/queue/zing/snipeit")
				msg = Hash.new
				
				if Models::Checkout.items.has_key?(tag.epc)
					# Checkout Item Detected
					item = Models::Checkout.items[tag.epc]

					logger.debug {"Checkout Item Detected"}
					msg["event"] = "Detected"
					msg["model"] = item.model
					msg["epc"] = item.epc
					msg["location"] = @location

				else
					# Non-Checkout Item Detected
					logger.debug {"Non-Checkout Item Detected"}
					toggle(@gpioAlarm)

					msg["event"] = "Alarm"
					msg["model"] = "Unknown"
					msg["epc"] = tag.epc
					msg["location"] = @location
				end

				pub.publish(msg)
			else
				logger.debug {"Non-AD Tag Ignored"}
			end
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