
#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"..")

class Tag
	include Logging

	attr_reader :epc, :reader, :antenna, :timestamp, :tzoffset

	def initialize(data)
		@epc = [data[1]].pack('H*').strip
		@reader = data[2]
		@antenna = data[3]
		@timestamp = data[4]
		@tzoffset = data[5]
	end

	def inspect
			"---------------\nepc=#{@epc}\nreader=#{@reader}\nantenna=#{@antenna}\ntimestamp=#{@timestamp}\ntzoffset=#{@tzoffset}\n---------------"
	end
end