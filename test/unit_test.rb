#Add the default relative library location to the search path
$:.unshift File.expand_path("..", Dir.pwd)
$:.unshift File.expand_path("../Models", Dir.pwd)
$:.unshift File.expand_path("../Controllers", Dir.pwd)

require "Logging"
#require "sqlite3"
#require "json"
require "thread"
require "mqttController"


begin
mqttServer = "localhost"
mqttPort = 1883
mqttSubTopic = "/queue/zing/snipeit/door"
#msg = JSON.parse('{"action":"create","data":{"id":"14","model":"UHF ISO CARD","epc":"400041443030303120202020202020202020","policy":{"Mon":"0-24","Tue":"0-24","Wed":"0-24","Thu":"0-24","Fri":"0-24","Sat":"0-24","Sun":"0-24"}}}')
#msg = JSON.parse('{"action":"delete","data":{"id":"14"}}')
#msg = JSON.parse('{"action":"create","data":{"id":4,"model":"Canon 60D","epc":"AD000001","policy":{"Mon":null,"Tue":null,"Wed":null,"Thu":null,"Fri":null,"Sat":null,"Sun":null}}}')
#model = Models::Checkout.new
#model.send(msg["action"], msg["data"])
sub = MqttController.new(mqttServer, mqttPort, mqttSubTopic)
sub.start

rescue Exception => e
puts e.inspect
end


