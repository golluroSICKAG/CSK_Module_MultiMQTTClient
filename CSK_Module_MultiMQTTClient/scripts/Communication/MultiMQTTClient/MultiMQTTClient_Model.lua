---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiMQTTClient'

-- Create kind of "class"
local multiMQTTClient = {}
multiMQTTClient.__index = multiMQTTClient

-- Get device type
local typeName = Engine.getTypeName()
if typeName == 'AppStudioEmulator' or typeName == 'SICK AppEngine' then
  multiMQTTClient.deviceType = 'AppEngine'
else
  multiMQTTClient.deviceType = string.sub(typeName, 1, 7)
end

multiMQTTClient.styleForUI = 'None' -- Optional parameter to set UI style
multiMQTTClient.version = Engine.getCurrentAppVersion() -- Version of module

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  multiMQTTClient.styleForUI = theme
  Script.notifyEvent("MultiMQTTClient_OnNewStatusCSKStyle", multiMQTTClient.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to create new instance
---@param multiMQTTClientInstanceNo int Number of instance
---@return table[] self Instance of multiMQTTClient
function multiMQTTClient.create(multiMQTTClientInstanceNo)

  local self = {}
  setmetatable(self, multiMQTTClient)

  self.multiMQTTClientInstanceNo = multiMQTTClientInstanceNo -- Number of this instance
  self.multiMQTTClientInstanceNoString = tostring(self.multiMQTTClientInstanceNo) -- Number of this instance as string
  self.helperFuncs = require('Communication/MultiMQTTClient/helper/funcs') -- Load helper functions
  self.ethernetPorts = Engine.getEnumValues("EthernetInterfaces") -- Available interfaces of device running the app
  self.ethernetPortsList = self.helperFuncs.createJsonList(self.ethernetPorts)

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Check if this instance is currently active in UI

  self.isConnected = false -- Status if connected to broker

  self.tempSubscriptionTopic = '' -- temporary preset topic to subscribe
  self.tempSubscriptionQOS = 'QOS0' -- temporary preset qos of topic to subscribe

  self.tempPublishEvent = '' -- temporary preset name of event to register to publish its content
  self.tempPublishTopic = '' -- temporary preset topic to publish
  self.tempPublishData = '' -- temporary preset data to publish
  self.tempPublishQOS = 'QOS0' -- temporary preset qos of topic to publish preset data
  self.tempPublishRetain = 'NO_RETAIN' -- temporary preset retain flag of topic to publish preset data

  self.publishEventsFunctions = {} -- Function(s) to use to publish if event was notified

  self.key = '1234567890123456' -- key to encrypt passwords, should be adapted!

  -- Check if CSK_PersistentData module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Default values for persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiMQTTClient_Parameter' .. self.multiMQTTClientInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters.processingFile = 'CSK_MultiMQTTClient_Processing' -- which file to use for processing (will be started in own thread)

  self.parameters.connect = false -- Config if connection should be active
  self.parameters.brokerIP = '192.168.1.100' -- IP of the MQTT broker
  self.parameters.brokerPort = 1883 -- Default port for MQTT. If using TLS it should be 8883
  self.parameters.connectionTimeout = 5000 -- The timeout to wait initially until the client gets connected
  self.parameters.cleanSession = true -- Clean session flag. See MQTTClient docu of AppEngine
  self.parameters.mqttClientID = 'CSK_MQTTClient_' .. self.multiMQTTClientInstanceNoString -- Sets the Client identifier of this MQTTClient instance.
  self.parameters.tlsVersion = 'NO_TLS' -- TLS version to use
  self.parameters.peerVerification = true -- Enables/disables peer verification
  self.parameters.hostnameVerification = false -- Enables/disables hostname verification
  self.parameters.useCredentials = false -- Enables/disables to use user credentials
  self.parameters.username = 'user' -- Username if using user credentials
  if _G.availableAPIs.specific == true then
    self.parameters.password = Cipher.AES.encrypt('password', self.key) -- Password if using user credentials
  end

  self.parameters.clientCertificateActive = false -- Enables/disables client certification
  self.parameters.clientCertificatePath = 'public/cert.pem' -- Path to a certificate file in PEM/DER/PKCS#12 format.
  self.parameters.clientCertificateKeyPath = 'public/privateKey.pem' -- Path to file containing the client�s private key in PEM/DER format.
  self.parameters.clientCertificateKeyPassword = '' -- Optional passphrase for the private key. If empty, it will be ignored

  self.parameters.caBundleActive = false -- Enables/disables to use certificate authority bundle
  self.parameters.caBundlePath = 'public/CA.pem' -- Path to a certificate bundle in PEM format.

  self.parameters.useWillMessage = false -- Enables/disables to use a will message
  self.parameters.disconnectWithWillMessage = false -- Enables/disables sending a will message before intentionally disconnecting
  self.parameters.willMessageTopic = '' -- Topic under which to publish the will message
  self.parameters.willMessageData = '' -- The message payload to publish
  self.parameters.willMessageQOS = 'QOS0' -- Quality of Service level
  self.parameters.willMessageRetain = 'NO_RETAIN' -- Retaining a message means that the server stores the message and sends it to future subscribers of this topic.

  self.parameters.keepAliveInterval = 60 -- The number of seconds after which a PING message should be sent if no other messages have been exchanged in that time. Disable keep alive mechanism with 0.
  self.parameters.forwardReceives = false -- Enables/disables if module should forward incoming receives via event 'CSK_MultiMQTTClient.OnReceive' and 'CSK_MultiMQTTClient.OnReceiveNUM'

  self.parameters.publishEvents = {} -- Register to these events to publish their content, see "addPublishEvent"
  self.parameters.publishEvents.topic = {} -- Topic to publish to if event was notified
  self.parameters.publishEvents.qos = {} -- QoS to publish if event was notified
  self.parameters.publishEvents.retain = {} -- Retain option of publish if event was notified
  -- self.parameters.publishEvents.topic[eventname] = 'topic/test' -- example
  -- self.parameters.publishEvents.qos[eventname] = 'QOS0' -- example
  -- self.parameters.publishEvents.retain[eventname] = 'NO_REATAIN' -- example

  self.parameters.interface = self.ethernetPorts[1] -- Select first of available ethernet interfaces

  self.parameters.subscriptions = {} -- Topics to subscribe incl. QoS
  -- self.parameters.subscriptions[topic] = QoS -- example for entries

  -- Parameters to give to the processing script
  self.multiMQTTClientProcessingParams = Container.create()
  self.multiMQTTClientProcessingParams:add('multiMQTTClientInstanceNumber', multiMQTTClientInstanceNo, "INT")

  self.multiMQTTClientProcessingParams:add('connect', self.parameters.connect, "BOOL")
  self.multiMQTTClientProcessingParams:add('brokerIP', self.parameters.brokerIP, "STRING")
  self.multiMQTTClientProcessingParams:add('brokerPort', self.parameters.brokerPort, "INT")
  self.multiMQTTClientProcessingParams:add('connectionTimeout', self.parameters.connectionTimeout, "INT")
  self.multiMQTTClientProcessingParams:add('cleanSession', self.parameters.cleanSession, "BOOL")
  self.multiMQTTClientProcessingParams:add('mqttClientID', self.parameters.mqttClientID, "STRING")
  self.multiMQTTClientProcessingParams:add('tlsVersion', self.parameters.tlsVersion, "STRING")
  self.multiMQTTClientProcessingParams:add('peerVerification', self.parameters.peerVerification, "BOOL")
  self.multiMQTTClientProcessingParams:add('hostnameVerification', self.parameters.hostnameVerification, "BOOL")
  self.multiMQTTClientProcessingParams:add('useCredentials', self.parameters.useCredentials, "BOOL")
  self.multiMQTTClientProcessingParams:add('username', self.parameters.username, "STRING")
  self.multiMQTTClientProcessingParams:add('passwords', self.parameters.password, "BINARY")
  self.multiMQTTClientProcessingParams:add('key', self.key, "STRING")

  self.multiMQTTClientProcessingParams:add('clientCertificateActive', self.parameters.clientCertificateActive, "BOOL")
  self.multiMQTTClientProcessingParams:add('clientCertificatePath', self.parameters.clientCertificatePath, "STRING")
  self.multiMQTTClientProcessingParams:add('clientCertificateKeyPath', self.parameters.clientCertificateKeyPath, "STRING")
  self.multiMQTTClientProcessingParams:add('clientCertificateKeyPassword', self.parameters.clientCertificateKeyPassword, "STRING")

  self.multiMQTTClientProcessingParams:add('caBundleActive', self.parameters.caBundleActive, "BOOL")
  self.multiMQTTClientProcessingParams:add('caBundlePath', self.parameters.caBundlePath, "STRING")

  self.multiMQTTClientProcessingParams:add('useWillMessage', self.parameters.useWillMessage, "BOOL")
  self.multiMQTTClientProcessingParams:add('disconnectWithWillMessage', self.parameters.disconnectWithWillMessage, "BOOL")
  self.multiMQTTClientProcessingParams:add('willMessageTopic', self.parameters.willMessageTopic, "STRING")
  self.multiMQTTClientProcessingParams:add('willMessageData', self.parameters.willMessageData, "STRING")
  self.multiMQTTClientProcessingParams:add('willMessageQOS', self.parameters.willMessageQOS, "STRING")
  self.multiMQTTClientProcessingParams:add('willMessageRetain', self.parameters.willMessageRetain, "STRING")

  self.multiMQTTClientProcessingParams:add('keepAliveInterval', self.parameters.keepAliveInterval, "INT")
  self.multiMQTTClientProcessingParams:add('forwardReceives', self.parameters.forwardReceives, "BOOL")

  self.multiMQTTClientProcessingParams:add('interface', self.parameters.interface, "STRING")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiMQTTClientProcessingParams)

  return self
end


return multiMQTTClient

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************