require 'rubygems'
require 'bundler/setup'
require 'mqtt'


MQTT::Client.connect('localhost', 1883) do |c|
	c.get('/queue/zing/snipeit/door') do |topic, message|
		puts "#{topic}: #{message}"
	end
end



