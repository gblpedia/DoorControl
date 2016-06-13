#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"Controllers")

require "Logging"
require "readerListener"
require "doorController"
require "detectionController"
require "mqttController"

begin
	include Logging
	doorGPIO = 14
	alarmGPIO = 15
	antDoor = "1"
	antDetection = "0"
	mqttServer = "localhost"
	mqttPort = 1883
	mqttSubTopic = "/queue/zing/snipeit/door"
	mqttPubTopic = "/queue/zing/snipeit"

	logger.debug { "DoorControl Client Starts..." }
	detectioncontrol = DetectionController.new(alarmGPIO)
	doorcontrol = DoorController.new(doorGPIO)
	mqttcontrol = MqttController.new(mqttServer, mqttPort, mqttSubTopic)
	detectioncontrol.start
	doorcontrol.start
	mqttcontrol.start

	listener = ReaderListener.new(4000)
	listener.queues[antDoor] = doorcontrol.tagsQueue;
	listener.queues[antDetection] = detectioncontrol.tagsQueue
	listener.start

end
