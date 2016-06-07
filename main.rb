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
	mqttServer = "128.199.200.73"
	mqttPort = 1883
	mqttTopic = "/queue/zing/snipeit/door"

	logger.debug { "DoorControl Client Starts..." }
	detectioncontrol = DetectionController.new(alarmGPIO)
	doorcontrol = DoorController.new(doorGPIO)
	mqttcontrol = MqttController.new(mqttServer, mqttPort, mqttTopic)
	detectioncontrol.start
	doorcontrol.start
	mqttcontrol.start

	listener = ReaderListener.new(4000)
	listener.queues[antDoor] = doorcontrol.tagsQueue;
	listener.queues[antDetection] = detectioncontrol.tagsQueue
	listener.start

end