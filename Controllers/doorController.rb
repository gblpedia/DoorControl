#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"..","Models")

require "thread"
require "checkout"
require "publisherMqtt"

class DoorController
	include Logging

	attr_reader :tagsQueue

	def initialize(gpioDoor, outside, inside)
		@location = "Door"
		@gpioDoor = gpioDoor;
		@tagsQueue = Queue.new
		@outside = outside
		@inside = inside
		@gpioFlag = false
		
		logger.debug { "init #{self.class.name}" }
	end

	def process
		begin
			logger.debug { "DoorController Starts a thread" }

			# Need to put in configuration
			pub = MqttPublisher.new("192.168.1.63", "/queue/zing/snipeit")
			
			while tag = @tagsQueue.pop
				logger.debug { "DoorController Pops a tag \n#{tag.epc}" }

				
				msg = Hash.new
				msg["action"] = "Event"

				# Deteted Tags in checkout list or not
				if Models::Checkout.items.has_key?(tag.epc)

					item = Models::Checkout.items[tag.epc]

					if tag.antenna == @outside
						
						if item.model == 'UHF ISO CARD' && item.isAllowed
							logger.debug {"Door Accessed In"}

							msg["event"] = "In"
							toggle(@gpioDoor)

						else
							logger.debug {"Door Access Denied due to Policy"}
							msg["event"] = "Denied"
						end

					else
						logger.debug {"Door Accessed Out, Always"}
						msg["event"] = "Out"

						# Alwasy allow peope go out
						toggle(@gpioDoor)
					end

					msg["model"] = item.model
					msg["epc"] = item.epc
					msg["location"] = @location
					msg["assigned_to"] = item.assigned_to

				else
					logger.debug {"Door Access Denied due to unknown tag"}
					
					msg["event"] = "Denied"
					msg["model"] = "Unknown"
					msg["epc"] = tag.epc
					msg["location"] = @location
					msg["assigned_to"] = "Unknown"
				end

				pub.publish(msg)

			end

		rescue Exception => e
			logger.debug {"DoorController Exception thrown: #{e.inspect}"}

		ensure
			logger.info {"DoorController Re-Starts a thread"}
			start
		end
	end

	def start
		Thread.new {self.process}
	end

	def toggle(gpio)

		Thread.new {
			@gpioFlag = true
			logger.debug {"toggle GPIO #{gpio} on"}
			system("sudo sh -c 'echo 1 > /sys/class/gpio/gpio#{gpio}/value'")
			sleep(2)
			logger.debug {"toggle GPIO #{gpio} off"}
			system("sudo sh -c 'echo 0 > /sys/class/gpio/gpio#{gpio}/value'")
			@gpioFlag = false
		} unless @gpioFlag
	end
end
