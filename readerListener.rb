require "socket"
require "tag"

class ReaderListener
	include Logging

	attr_accessor :queues

	def initialize(port)
		@queues = Hash.new
		@server = TCPServer.new('', port.to_i)
	end

	def start
		loop do
			socket = @server.accept
			sock_domain, remote_port, remote_hostname, remote_ip = socket.peeraddr
			logger.debug { "Client connected from #{remote_ip} !" }

			while line = socket.gets
				line = line.chomp.strip
				logger.debug { "Received #{line}" }

				if  /TAG/.match(line)
					data = line.split('|')
					tag = Tag.new(data)
					@queues[tag.antenna] << tag
				else
					logger.debug { "Client disconnected!" }
				end
			end
		end
	end
end