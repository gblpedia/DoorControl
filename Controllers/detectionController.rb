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
		@gpioFlag = false
		logger.debug { "init #{self.class.name}" }
	end

	def process
		begin
			logger.debug { "DetectionController Starts a thread" }

			while tag = @tagsQueue.pop
				logger.debug { "DetectionController Pops a tag \n#{tag.epc}" }

				if tag.epc.start_with?("AD")
					# Need to put in configuration
					pub = MqttPublisher.new("192.168.1.63", "/queue/zing/snipeit")
					msg = Hash.new
					msg["action"] = "Event"
					
					if Models::Checkout.items.has_key?(tag.epc)
						# Checkout Item Detected
						item = Models::Checkout.items[tag.epc]

						logger.debug {"Checkout Item Detected"}
						msg["event"] = "Detected"
						msg["model"] = item.model
						msg["epc"] = item.epc
						msg["location"] = @location
						msg["assigned_to"] = item.assigned_to

					else
						# Non-Checkout Item Detected
						logger.debug {"Non-Checkout Item Detected"}
						toggle(@gpioAlarm)

						msg["event"] = "Alarm"
						msg["model"] = "Unknown"
						msg["epc"] = tag.epc
						msg["location"] = @location
						msg["assigned_to"] = "Unknown"
					end

					pub.publish(msg)

				else
					logger.debug {"Non-AD Tag Ignored"}
				end
			end

		rescue Excpetion => e
			logger.debug {"DetectionController Exception thrown: #{e.inspect}"}

		ensure
			logger.info {"DetectionController Re-Starts a thread"}
			start
		end
	end

	def start
		Thread.new {self.process}
	end

	def toggle(gpio)
		@toggleThread = Thread.new {
			logger.debug {"Alarm On"}
			@gpioFlag = true
			(1..10).each do |i|
				system("sudo sh -c 'echo 0 > /sys/class/gpio/gpio#{gpio}/value'")
				sleep(0.2)
				logger.debug {"#{i} toggle GPIO #{gpio} off"}
				system("sudo sh -c 'echo 1 > /sys/class/gpio/gpio#{gpio}/value'")
				sleep(0.4)
			end
			@gpioFlag = false
			logger.debug {"Alarm Off"}
		} unless @gpioFlag
	end
end
