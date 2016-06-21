#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"Controllers")

require 'rubygems'
require 'bundler/setup'

require "Logging"
require "readerListener"
require "doorController"
require "detectionController"
require "mqttController"

begin
	include Logging
	doorGPIO = 14
	alarmGPIO = 15
	antDoorOutside = "1"
	antDoorInsdie = "2"
	antDetection = "0"
	mqttServer = "192.168.1.63"
	mqttPort = 1883
	mqttSubTopic = "/queue/zing/snipeit/door"
	mqttPubTopic = "/queue/zing/snipeit"

	logger.debug { "DoorControl Client Starts..." }
	detectioncontrol = DetectionController.new(alarmGPIO)
	doorcontrol = DoorController.new(doorGPIO, antDoorOutside, antDoorInsdie)
	mqttcontrol = MqttController.new(mqttServer, mqttPort, mqttSubTopic)
	detectioncontrol.start
	doorcontrol.start
	mqttcontrol.start

	listener = ReaderListener.new(4000)
	listener.queues[antDoorOutside] = doorcontrol.tagsQueue;
	listener.queues[antDoorInsdie] = doorcontrol.tagsQueue;
	listener.queues[antDetection] = detectioncontrol.tagsQueue
	listener.start

rescue SystemExit, Interrupt => e
	puts e.inspect

end
