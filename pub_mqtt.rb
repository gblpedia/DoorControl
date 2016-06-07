require 'rubygems'
require 'mqtt'

MQTT::Client.connect('128.199.200.73', 1883) do |c|
	topic = '/queue/zing/snipeit/door'
	message = '{"action":"create","data":{"id":"14","model_name":"UHF ISO CARD","epc":"400041443030303120202020202020202020","policy":{"Mon":"0-24","Tue":"0-24","Wed":"0-24","Thu":"0-24","Fri":"0-24","Sat":"0-24","Sun":"0-24"}}}'
	c.publish(topic, message)
	puts "Publish #{message} on #{topic}"
end
