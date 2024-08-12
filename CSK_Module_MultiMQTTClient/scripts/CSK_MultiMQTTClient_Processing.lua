---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('Communication/MultiMQTTClient/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiMQTTClient'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local deviceType = ''
-- Get device type
local typeName = Engine.getTypeName()
if typeName == 'AppStudioEmulator' or typeName == 'SICK AppEngine' then
  deviceType = 'AppEngine'
else
  deviceType = string.sub(typeName, 1, 7)
end

local mqttClient
local messageLog = {}
local isConnected = false

local reconnectionTimer = Timer.create() -- Timer to reconnect in case the connection to the broker is lost
reconnectionTimer:setExpirationTime(5000)
reconnectionTimer:setPeriodic(false)

if availableAPIs.specific == true then
  mqttClient = MQTTClient.create()
end

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiMQTTClientInstanceNumber = scriptParams:get('multiMQTTClientInstanceNumber') -- number of this instance
local multiMQTTClientInstanceNumberString = tostring(multiMQTTClientInstanceNumber) -- number of this instance as string

-- Event to notify result of processing
Script.serveEvent("CSK_MultiMQTTClient.OnReceive" .. multiMQTTClientInstanceNumberString, "MultiMQTTClient_OnReceive" .. multiMQTTClientInstanceNumberString, 'string, binary, enum:?:CSK_MultiMQTTClient.QOS, enum:?:CSK_MultiMQTTClient.Retain')
-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiMQTTClient.OnNewValueToForward".. multiMQTTClientInstanceNumberString, "MultiMQTTClient_OnNewValueToForward" .. multiMQTTClientInstanceNumberString, 'string, auto, auto:?, auto:?, auto:?')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiMQTTClient.OnNewValueUpdate" .. multiMQTTClientInstanceNumberString, "MultiMQTTClient_OnNewValueUpdate" .. multiMQTTClientInstanceNumberString, 'int, string, auto, int:?')

local processingParams = {}
processingParams.activeInUI = false

processingParams.connect = scriptParams:get('connect')
processingParams.brokerIP = scriptParams:get('brokerIP')
processingParams.brokerPort = scriptParams:get('brokerPort')
processingParams.connectionTimeout = scriptParams:get('connectionTimeout')
processingParams.cleanSession = scriptParams:get('cleanSession')
processingParams.mqttClientID = scriptParams:get('mqttClientID')
processingParams.tlsVersion = scriptParams:get('tlsVersion')
processingParams.peerVerification = scriptParams:get('peerVerification')
processingParams.hostnameVerification = scriptParams:get('hostnameVerification')
processingParams.useCredentials = scriptParams:get('useCredentials')
processingParams.username = scriptParams:get('username')
processingParams.password = scriptParams:get('password')
processingParams.key = scriptParams:get('key')

processingParams.clientCertificateActive = scriptParams:get('clientCertificateActive')
processingParams.clientCertificatePath = scriptParams:get('clientCertificatePath')
processingParams.clientCertificateKeyPath = scriptParams:get('clientCertificateKeyPath')
processingParams.clientCertificateKeyPassword = scriptParams:get('clientCertificateKeyPassword')

processingParams.caBundleActive = scriptParams:get('caBundleActive')
processingParams.caBundlePath = scriptParams:get('caBundlePath')

processingParams.useWillMessage = scriptParams:get('useWillMessage')
processingParams.disconnectWithWillMessage = scriptParams:get('disconnectWithWillMessage')
processingParams.willMessageTopic = scriptParams:get('willMessageTopic')
processingParams.willMessageData = scriptParams:get('willMessageData')
processingParams.willMessageQOS = scriptParams:get('willMessageQOS')
processingParams.willMessageRetain = scriptParams:get('willMessageRetain')

processingParams.keepAliveInterval = scriptParams:get('keepAliveInterval')
processingParams.forwardReceives = scriptParams:get('forwardReceives')

processingParams.interface = scriptParams:get('interface')

processingParams.publishEvents = {}
processingParams.publishEvents.topic = {}
processingParams.publishEvents.qos = {}
processingParams.publishEvents.retain = {}

processingParams.subscriptions = {}

processingParams.publishEventsFunctions = {}

--- Function to create and notify internal MQTT log messages
local function sendLog()
  local tempLog2Send = ''
  for i=#messageLog, 1, -1 do
    tempLog2Send = tempLog2Send .. messageLog[i] .. '\n'
  end
  if processingParams.activeInUI then
    Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnNewLog', tempLog2Send)
  end
end

--- Function to add new message to internal MQTT log messages
---@param msg string Message
local function addMessageLog(msg)
  table.insert(messageLog, 1, DateTime.getTime() .. ': ' .. msg)
  if #messageLog == 200 then
    table.remove(messageLog, 200)
  end
  sendLog()
end

--- Function to react on "OnReceive" event of MQTT client
---@param topic string The topic the message was posted to
---@param data binary The payload data that was received
---@param qos MQTTClient.QOS The Quality of Service level
---@param retain MQTTClient.Retain The message retain flag
local function handleOnReceive(topic, data, qos, retain)

  addMessageLog('[Topic]: ' .. topic .. ', [Data]: ' .. tostring(data) .. ', [QoS]: ' .. qos .. ', [Retain]: ' .. retain)

  if processingParams.forwardReceives and processingParams.activeInUI then
    Script.notifyEvent('MultiMQTTClient_OnReceive' .. multiMQTTClientInstanceNumberString, topic, data, qos, retain)
    if processingParams.activeInUI then
      Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnReceive', topic, data, qos, retain)
    end
    --Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnReceiveFullString', topic .. ';' .. tostring(data) .. ';' .. qos .. ';' .. retain)
  end

end
if availableAPIs.default and availableAPIs.specific == true then
  MQTTClient.register(mqttClient, 'OnReceive', handleOnReceive)
end

--- Function to subscribe to a topic on a MQTT broker
---@param topicFilter string The topic which to subscribe to.
---@param qos string Quality of Service level. Default is QOS0
local function subscribe(topicFilter, qos)
  MQTTClient.subscribe(mqttClient, topicFilter, qos)
end

--- Function to subscribe to all configured topics
local function subscripeToAllTopics()
  for key, value in pairs(processingParams.subscriptions) do
    subscribe(key, value)
  end
end

--- Function to react on "OnConnected" event of MQTT client
local function handleOnConnected()
  _G.logger:info(nameOfModule .. ": Connected to MQTT broker.")
  addMessageLog('Connected to MQTT broker.')
  reconnectionTimer:stop()
  isConnected = true
  Script.notifyEvent('MultiMQTTClient_OnNewValueUpdate' .. multiMQTTClientInstanceNumberString, multiMQTTClientInstanceNumber, 'isConnected', isConnected)
  if processingParams.activeInUI then
    Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnNewConnectionStatus', "Connected to MQTT Broker")
    Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnNewStatusCurrentlyConnected', isConnected)
  end
  subscripeToAllTopics()
end
if availableAPIs.default and  availableAPIs.specific == true then
  MQTTClient.register(mqttClient, 'OnConnected', handleOnConnected)
end

--- Function to react on "OnDisconnected" event of MQTT client
local function handleOnDisconnected()
  _G.logger:info(nameOfModule .. ": Disconnected from MQTT broker.")
  addMessageLog('Disconnected from MQTT broker.')
  if processingParams.connect == true then
    MQTTClient.connect(mqttClient, processingParams.connectionTimeout)
    if mqttClient:isConnected() == false then
      addMessageLog("Disconnected from MQTT broker, starting reconnection timer")
      reconnectionTimer:start()
    end
  end
  isConnected = false
  Script.notifyEvent('MultiMQTTClient_OnNewValueUpdate' .. multiMQTTClientInstanceNumberString, multiMQTTClientInstanceNumber, 'isConnected', isConnected)
  if processingParams.activeInUI then
    Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnNewConnectionStatus', 'Disabled')
    Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnNewStatusCurrentlyConnected', isConnected)
  end
end
if availableAPIs.default and availableAPIs.specific == true then
  MQTTClient.register(mqttClient, 'OnDisconnected', handleOnDisconnected)
end

--- Function to reset the MQTTClient
local function recreateMQTTClient()
  Script.releaseObject(mqttClient)
  mqttClient = MQTTClient.create()
  MQTTClient.register(mqttClient, 'OnReceive', handleOnReceive)
  MQTTClient.register(mqttClient, 'OnConnected', handleOnConnected)
  MQTTClient.register(mqttClient, 'OnDisconnected', handleOnDisconnected)
end

local function publish(topic, data, qos, retain)
  _G.logger:fine(nameOfModule .. ": Publish data '" .. tostring(data) .. "' to topic '" .. topic .. "' with QoS '" .. qos .. "' and '" .. retain .. "'")
  addMessageLog("Publish data '" .. tostring(data) .. "' to topic '" .. topic .. "' with QoS '" .. qos .. "' and '" .. retain .. "'")
  MQTTClient.publish(mqttClient, topic, tostring(data), qos, retain)
end

local function connectMQTT(status)
  processingParams.connect = status

  if status == true then
    recreateMQTTClient()
    MQTTClient.setIPAddress(mqttClient, processingParams.brokerIP)
    MQTTClient.setPort(mqttClient, processingParams.brokerPort)
    MQTTClient.setClientID(mqttClient, processingParams.mqttClientID)
    MQTTClient.setCleanSession(mqttClient, processingParams.cleanSession)

    if deviceType ~= 'AppEngine' then
      MQTTClient.setInterface(mqttClient, processingParams.interface)
    end
    MQTTClient.setKeepAliveInterval(mqttClient, processingParams.keepAliveInterval)
    if processingParams.useCredentials then
      MQTTClient.setUserCredentials(mqttClient, processingParams.username, Cipher.AES.decrypt(processingParams.password, processingParams.key))
    end
    if processingParams.useWillMessage then
      MQTTClient.setWillMessage(mqttClient, processingParams.willMessageTopic, processingParams.willMessageData, processingParams.willMessageQOS, processingParams.willMessageRetain)
    end

    if processingParams.tlsVersion == 'NO_TLS' then
      MQTTClient.setTLSEnabled(mqttClient, false)
      _G.logger:info(nameOfModule .. ": TLS and related features not enabled.")
    else
      MQTTClient.setTLSEnabled(mqttClient, true)
      MQTTClient.setTLSVersion(mqttClient, processingParams.tlsVersion)
      MQTTClient.setHostnameVerification(mqttClient, processingParams.hostnameVerification)
      MQTTClient.setPeerVerification(mqttClient, processingParams.peerVerification)

      if processingParams.clientCertificateActive == true then
        if processingParams.clientCertificateKeyPassword ~= '' then
          MQTTClient.setClientCertificate(mqttClient, processingParams.clientCertificatePath, processingParams.clientCertificateKeyPath)
        else
          MQTTClient.setClientCertificate(mqttClient, processingParams.clientCertificatePath, processingParams.clientCertificateKeyPath, Cipher.AES.decrypt(processingParams.clientCertificateKeyPassword, processingParams.key))
        end
      end

      if processingParams.caBundleActive == true then
        MQTTClient.setCABundle(mqttClient, processingParams.caBundlePath)
      end
    end
    MQTTClient.connect(mqttClient, processingParams.connectionTimeout)
    if mqttClient:isConnected() == false then
      addMessageLog("Connection failed")
      if processingParams.activeInUI then
        Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnNewConnectionStatus', 'Connection failed, starting reconnection timer')
      end

      reconnectionTimer:start()
    end
  else
    if processingParams.disconnectWithWillMessage == true and processingParams.useWillMessage == true then
      publish(processingParams.willMessageTopic, processingParams.willMessageData, processingParams.willMessageQOS, processingParams.willMessageRetain)
    end
    MQTTClient.disconnect(mqttClient)
    reconnectionTimer:stop()
  end
end

--- Function to reconnect to broker if the connection is lost
local function handleOnReconnectionTimerExpired()
  if processingParams.connect == true then
    MQTTClient.connect(mqttClient, processingParams.connectionTimeout)
    if mqttClient:isConnected() == false then
      _G.logger:info(nameOfModule .. ": Reconnection trial to MQTT Broker failed.")
      if processingParams.activeInUI then
        Script.notifyEvent('MultiMQTTClient_OnNewValueToForward' .. multiMQTTClientInstanceNumberString, 'MultiMQTTClient_OnNewConnectionStatus', "Reconnection trial failed, trying again in 5s")
      end
      addMessageLog("Reconnection trial failed, trying again in 5s")
      reconnectionTimer:start()
    end
  end
end
reconnectionTimer:register('OnExpired', handleOnReconnectionTimerExpired)

--- Function to deregister from event
local function deregisterFromEvent()
  _G.logger:fine(nameOfModule .. ": Deregister instance " .. multiMQTTClientInstanceNumberString .. " from event.")
  Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
  processingParams.registeredEvent = ''
end

local function createInternalPublishFunctions(event)
  local function triggerPublish(event, data)
    if isConnected then
      publish(processingParams.publishEvents.topic[event], data, processingParams.publishEvents.qos[event], processingParams.publishEvents.retain[event])
    else
      _G.logger:info(nameOfModule .. ": Publish not possible because not connected")
    end
  end

  local function forwardContent(data)
    triggerPublish(event, data)
  end
  processingParams.publishEventsFunctions[event] = forwardContent
end

--- Function to handle updates of processing parameters from Controller
---@param multiMQTTClientNo int Number of instance to update
---@param parameter string Parameter to update
---@param valueA auto? Value of parameter to update
---@param valueB auto? Value of parameter to update
---@param valueC auto? Value of parameter to update
---@param valueD auto? Value of parameter to update
local function handleOnNewProcessingParameter(multiMQTTClientNo, parameter, valueA, valueB, valueC, valueD)

  if multiMQTTClientNo == multiMQTTClientInstanceNumber then -- set parameter only in selected script
    if valueA then
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiMQTTClientInstanceNo." .. tostring(multiMQTTClientNo) .. " to value = " .. tostring(valueA))
    else
      _G.logger:fine(nameOfModule .. ": Update '" .. parameter .. "' of multiMQTTClientInstanceNo." .. tostring(multiMQTTClientNo))
    end

    if parameter == 'sendLog' then
      sendLog()

    elseif parameter == 'useCredentials' then
      processingParams[parameter] = valueA
      if valueA then
        MQTTClient.setUserCredentials(mqttClient, processingParams.username, Cipher.AES.decrypt(processingParams.passwords, processingParams.key))
      end

    elseif parameter == 'subscribe' then
      processingParams.subscriptions[valueA] = valueB
      if isConnected then
        subscribe(valueA, valueB)
      end

    elseif parameter == 'unsubscribe' then
      processingParams.subscriptions[valueA] = nil
      if isConnected then
        MQTTClient.unsubscribe(mqttClient, valueA)
      end

    elseif parameter == 'publish' then
      publish(valueA, valueB, valueC, valueD)

    elseif parameter == 'deregisterFromEvent' then
      deregisterFromEvent()

    elseif parameter == 'deregisterFromAllEvents' then
      for key in pairs(processingParams.publishEvents.topic) do
        Script.deregister(key, processingParams.publishEventsFunctions[key])
      end

    elseif parameter == 'connect' then
      connectMQTT(valueA)

    elseif parameter == 'createPublishFunction' then
      createInternalPublishFunctions(valueA)
      _G.logger:fine(nameOfModule .. ": Register to event '" .. valueA .. "' to forward its content via MQTT publish on topic '" .. processingParams.publishEvents.topic[valueA] .. "'")
      Script.register(valueA, processingParams.publishEventsFunctions[valueA])

    elseif parameter == 'addPublishEvent' then
      if processingParams.publishEventsFunctions[valueA] then
        Script.deregister(valueA, processingParams.publishEventsFunctions[valueA])
        processingParams.publishEventsFunctions[valueA] = nil
      end
      processingParams.publishEvents.topic[valueA] = valueB
      processingParams.publishEvents.qos[valueA] = valueC
      processingParams.publishEvents.retain[valueA] = valueD

      createInternalPublishFunctions(valueA)

      _G.logger:fine(nameOfModule .. ": Register to event '" .. valueA .. "' to forward its content via MQTT publish on topic '" .. processingParams.publishEvents.topic[valueA] .. "'")
      Script.register(valueA, processingParams.publishEventsFunctions[valueA])

    elseif parameter == 'removePublishEvent' then
      if processingParams.publishEvents.topic[valueA] then

        _G.logger:fine(nameOfModule .. ": Deregister from event '" .. valueA .. "' and remove this from the list.")
        processingParams.publishEvents.topic[valueA] = nil
        processingParams.publishEvents.qos[valueA] = nil
        processingParams.publishEvents.retain[valueA] = nil

        Script.deregister(valueA, processingParams.publishEventsFunctions[valueA])
        processingParams.publishEventsFunctions[valueA] = nil

      end

    elseif parameter == 'willMessageConfig' then
      processingParams.willMessageTopic = valueA
      processingParams.willMessageData = valueB
      processingParams.willMessageQOS = valueC
      processingParams.willMessageRetain = valueD

    else
      processingParams[parameter] = valueA
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiMQTTClient.OnNewProcessingParameter", handleOnNewProcessingParameter)
