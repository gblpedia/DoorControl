require 'rubygems'
require 'mqtt'

#128.199.200.73
MQTT::Client.connect('localhost', 1883) do |c|
	c.get('/queue/zing/snipeit/door') do |topic, message|
		puts "#{topic}: #{message}"
	end
end



