#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__))
$: << File.join(File.dirname(__FILE__),"/","Models")
$: << File.join(File.dirname(__FILE__),"/","Controllers")

require "Logging"
require "sqlite3"
require "json"
require "checkout"


begin
msg = JSON.parse('{"action":"create","data":{"id":"14","model":"UHF ISO CARD","epc":"400041443030303120202020202020202020","policy":{"Mon":"0-24","Tue":"0-24","Wed":"0-24","Thu":"0-24","Fri":"0-24","Sat":"0-24","Sun":"0-24"}}}')
#msg = JSON.parse('{"action":"delete","data":{"id":"14"}}')
model = Models::Checkout.new
model.send(msg["action"], msg["data"])

rescue Exception => e
puts e.inspect
ensure
model.close
end

#sub = MQTTController::Subscriber.new
