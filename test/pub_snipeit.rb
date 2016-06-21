require 'rubygems'
require 'mqtt'

MQTT::Client.connect('localhost', 1883) do |c|
	topic = '/queue/zing/snipeit'
        time = Time.new
	timestamp = time.strftime("%Y%m%d%H%M%S")
	#message = '{"action":"create","data":{"id":"14","model_name":"UHF ISO CARD","epc":"400041443030303120202020202020202020","assigned_to":"John Doe","policy":{"Mon":"0-24","Tue":"0-24","Wed":"0-24","Thu":"0-24","Fri":"0-24","Sat":"0-24","Sun":"0-24"}}}'
	
	#message = "{\"event\":\"Access\", \"model\":\"UHF ISO CARD\", \"epc\":\"41443030303120202020202020202020\", \"assigned_to\":\"John Doe\", \"location\":\"Door\", \"timestamp\":#{timestamp}}"
	message = "{\"action\":\"CheckoutList\"}"
	c.publish(topic, message)
	puts "Publish #{message} on #{topic}"
end
