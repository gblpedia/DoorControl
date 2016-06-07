require "thread"
require "checkout"

class DetectionController
	include Logging

	attr_reader :tagsQueue
	
	def initialize(gpio)
		@gpio = gpio;
		@tagsQueue = Queue.new
		logger.debug { "init #{self.class.name}" }
	end

	def process
		logger.debug { "DetectionController Starts a thread" }

		while tag = @tagsQueue.pop
			logger.debug { "DetectionController Pops a tag \n#{tag.epc}" }
			if Models::Checkout.items.has_key?(tag.epc)
				# Deteted user card in checkout list
				item = Models::Checkout.items[tag.epc]
				
				if item.isAllowed
					logger.debug {"publish message and open door"}
					toggle()
				end
			else
				# Detected user card is not in checkout list
				logger.debug {"publish message and alarm"}
			end
		end
	end

	def start
		Thread.new {self.process}
	end

	def toggle()
		logger.debug {"toggle GPIO #{@gpio} on"}
		sleep(2)
		logger.debug {"toggle GPIO #{@gpio} off"}
	end
end