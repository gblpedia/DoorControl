require 'rubygems'
require 'bundler/setup'
require 'mqtt'

local = 'localhost'
sng1 = '128.199.162.94'
sng3 = '128.199.200.73'
id = 'rubycyh7c0d5y33lsart'
mini = '192.168.1.63'
zing = 'zing.adilam.com.sg'
begin
	client = MQTT::Client.connect(:host => zing, :port => 1883, :client_id => id, :clean_session => false)
	puts 'client id ' + client.client_id + ' ' + id
	client.subscribe('/queue/zing/snipeit/door' => 1)
	client.get do |topic, message|
		puts "#{message}"
		puts "#{client.queue_empty?} #{client.queue_length}"
	end
rescue SystemExit, Interrupt => e
	puts e.inspect
rescue MQTT::Exception => e
	puts e.inspect
ensure
	puts 'disconnect'
	client.disconnect
end


