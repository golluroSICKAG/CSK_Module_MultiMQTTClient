---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiMQTTClient_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiMQTTClient'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiMQTTClient = Timer.create()
tmrMultiMQTTClient:setExpirationTime(300)
tmrMultiMQTTClient:setPeriodic(false)

local multiMQTTClient_Model -- Reference to model handle
local multiMQTTClient_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Communication/MultiMQTTClient/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiMQTTClient.processInstanceNUM", emptyFunction)

Script.serveEvent("CSK_MultiMQTTClient.OnReceiveNUM", "MultiMQTTClient_OnReceiveNUM")
Script.serveEvent("CSK_MultiMQTTClient.OnNewValueToForwardNUM", "MultiMQTTClient_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiMQTTClient.OnNewValueUpdateNUM", "MultiMQTTClient_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusModuleVersion', 'MultiMQTTClient_OnNewStatusModuleVersion')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusCSKStyle', 'MultiMQTTClient_OnNewStatusCSKStyle')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusModuleIsActive', 'MultiMQTTClient_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_MultiMQTTClient.OnReceive', 'MultiMQTTClient_OnReceive')
Script.serveEvent('CSK_MultiMQTTClient.OnReceiveFullString', 'MultiMQTTClient_OnReceiveFullString')
Script.serveEvent('CSK_MultiMQTTClient.OnNewConnectionStatus', 'MultiMQTTClient_OnNewConnectionStatus')

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusCurrentlyConnected', 'MultiMQTTClient_OnNewStatusCurrentlyConnected')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusActivateConnection', 'MultiMQTTClient_OnNewStatusActivateConnection')

Script.serveEvent('CSK_MultiMQTTClient.OnNewMQTTPort', 'MultiMQTTClient_OnNewMQTTPort')
Script.serveEvent('CSK_MultiMQTTClient.OnNewBrokerIP', 'MultiMQTTClient_OnNewBrokerIP')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusForwardReceivedMsg', 'MultiMQTTClient_OnNewStatusForwardReceivedMsg')

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusConnectionTimeout', 'MultiMQTTClient_OnNewStatusConnectionTimeout')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusClientID', 'MultiMQTTClient_OnNewStatusClientID')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusHostnameVerification', 'MultiMQTTClient_OnNewStatusHostnameVerification')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusTLS', 'MultiMQTTClient_OnNewStatusTLS')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusCleanSession', 'MultiMQTTClient_OnNewStatusCleanSession')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusPeerVerification', 'MultiMQTTClient_OnNewStatusPeerVerification')

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusClientCertificateActive', 'MultiMQTTClient_OnNewStatusClientCertificateActive')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusClientCertificatePath', 'MultiMQTTClient_OnNewStatusClientCertificatePath')
Script.serveEvent('CSK_MultiMQTTClient.OnNewstatusClientCertificateKeyPath', 'MultiMQTTClient_OnNewstatusClientCertificateKeyPath')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusCABundleActive', 'MultiMQTTClient_OnNewStatusCABundleActive')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusCABundlePath', 'MultiMQTTClient_OnNewStatusCABundlePath')

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusInterfaceList', 'MultiMQTTClient_OnNewStatusInterfaceList')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusInterface', 'MultiMQTTClient_OnNewStatusInterface')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusKeepAliveInterval', 'MultiMQTTClient_OnNewStatusKeepAliveInterval')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusUseCredentials', 'MultiMQTTClient_OnNewStatusUseCredentials')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusUsername', 'MultiMQTTClient_OnNewStatusUsername')

Script.serveEvent('CSK_MultiMQTTClient.OnNewLog', 'MultiMQTTClient_OnNewLog')

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusSubscriptionTopic', 'MultiMQTTClient_OnNewStatusSubscriptionTopic')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusSubscriptionQOS', 'MultiMQTTClient_OnNewStatusSubscriptionQOS')

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusPublishEventName', 'MultiMQTTClient_OnNewStatusPublishEventName')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusPublishTopic', 'MultiMQTTClient_OnNewStatusPublishTopic')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusPublishData', 'MultiMQTTClient_OnNewStatusPublishData')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusPublishQOS', 'MultiMQTTClient_OnNewStatusPublishQOS')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusPublishRetain', 'MultiMQTTClient_OnNewStatusPublishRetain')

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusSubscriptionList', 'MultiMQTTClient_OnNewStatusSubscriptionList')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusPublishEventList', 'MultiMQTTClient_OnNewStatusPublishEventList')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusWillMessageActive', 'MultiMQTTClient_OnNewStatusWillMessageActive')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusWillMessageConfig', 'MultiMQTTClient_OnNewStatusWillMessageConfig')
Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusDisconnectWithWillMessage', 'MultiMQTTClient_OnNewStatusDisconnectWithWillMessage')

--TODO--------------------------------------------------
Script.serveEvent('CSK_MultiMQTTClient.OnNewResult', 'MultiMQTTClient_OnNewResult')

Script.serveEvent("CSK_MultiMQTTClient.OnNewStatusLoadParameterOnReboot", "MultiMQTTClient_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiMQTTClient.OnPersistentDataModuleAvailable", "MultiMQTTClient_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiMQTTClient.OnNewParameterName", "MultiMQTTClient_OnNewParameterName")

Script.serveEvent("CSK_MultiMQTTClient.OnNewInstanceList", "MultiMQTTClient_OnNewInstanceList")
Script.serveEvent("CSK_MultiMQTTClient.OnNewProcessingParameter", "MultiMQTTClient_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiMQTTClient.OnNewSelectedInstance", "MultiMQTTClient_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiMQTTClient.OnDataLoadedOnReboot", "MultiMQTTClient_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiMQTTClient.OnUserLevelOperatorActive", "MultiMQTTClient_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiMQTTClient.OnUserLevelMaintenanceActive", "MultiMQTTClient_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiMQTTClient.OnUserLevelServiceActive", "MultiMQTTClient_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiMQTTClient.OnUserLevelAdminActive", "MultiMQTTClient_OnUserLevelAdminActive")

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiMQTTClient_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiMQTTClient_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiMQTTClient_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiMQTTClient_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param valueA auto Value to forward
---@param valueB auto? Value to forward
---@param valueC auto? Value to forward
---@param valueD auto? Value to forward
local function handleOnNewValueToForward(eventname, valueA, valueB, valueC, valueD)
  if valueB ~= nil and valueC ~= nil and valueD ~= nil then
    Script.notifyEvent(eventname, valueA, valueB, valueC, valueD)
  elseif valueB ~= nil and valueC ~= nil then
    Script.notifyEvent(eventname, valueA, valueB, valueC)
  elseif valueB ~= nil then
    Script.notifyEvent(eventname, valueA, valueB)
  else
    Script.notifyEvent(eventname, valueA)
  end
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
  multiMQTTClient_Instances[instance][parameter] = value
end

--- Function to get access to the multiMQTTClient_Model object
---@param handle handle Handle of multiMQTTClient_Model object
local function setMultiMQTTClient_Model_Handle(handle)
  multiMQTTClient_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiMQTTClient_Model_Handle = setMultiMQTTClient_Model_Handle

--- Function to get access to the multiMQTTClient_Instances object
---@param handle handle Handle of multiMQTTClient_Instances object
local function setMultiMQTTClient_Instances_Handle(handle)
  multiMQTTClient_Instances = handle
  if multiMQTTClient_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiMQTTClient_Instances do
    Script.register("CSK_MultiMQTTClient.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
  end

  for i = 1, #multiMQTTClient_Instances do
    Script.register("CSK_MultiMQTTClient.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end

end
funcs.setMultiMQTTClient_Instances_Handle = setMultiMQTTClient_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiMQTTClient_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiMQTTClient_OnUserLevelAdminActive", true)
    Script.notifyEvent("MultiMQTTClient_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiMQTTClient_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiMQTTClient_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiMQTTClient()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    updateUserLevel()

    Script.notifyEvent('MultiMQTTClient_OnNewSelectedInstance', selectedInstance)
    Script.notifyEvent("MultiMQTTClient_OnNewInstanceList", helperFuncs.createStringListBySize(#multiMQTTClient_Instances))

    Script.notifyEvent("MultiMQTTClient_OnNewStatusModuleVersion", multiMQTTClient_Instances[selectedInstance].version)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusCSKStyle", multiMQTTClient_Instances[selectedInstance].styleForUI)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

    Script.notifyEvent("MultiMQTTClient_OnNewStatusCurrentlyConnected", multiMQTTClient_Instances[selectedInstance].isConnected)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusActivateConnection", multiMQTTClient_Instances[selectedInstance].parameters.connect)

    Script.notifyEvent("MultiMQTTClient_OnNewBrokerIP", multiMQTTClient_Instances[selectedInstance].parameters.brokerIP)
    Script.notifyEvent("MultiMQTTClient_OnNewMQTTPort", multiMQTTClient_Instances[selectedInstance].parameters.brokerPort)

    Script.notifyEvent("MultiMQTTClient_OnNewStatusConnectionTimeout", multiMQTTClient_Instances[selectedInstance].parameters.connectionTimeout)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusClientID", multiMQTTClient_Instances[selectedInstance].parameters.mqttClientID)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusCleanSession", multiMQTTClient_Instances[selectedInstance].parameters.cleanSession)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusTLS", multiMQTTClient_Instances[selectedInstance].parameters.tlsVersion)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusHostnameVerification", multiMQTTClient_Instances[selectedInstance].parameters.hostnameVerification)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPeerVerification", multiMQTTClient_Instances[selectedInstance].parameters.peerVerification)

    Script.notifyEvent("MultiMQTTClient_OnNewStatusClientCertificateActive", multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateActive)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusClientCertificatePath", multiMQTTClient_Instances[selectedInstance].parameters.clientCertificatePath)
    Script.notifyEvent("MultiMQTTClient_OnNewstatusClientCertificateKeyPath", multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateKeyPath)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusCABundleActive", multiMQTTClient_Instances[selectedInstance].parameters.caBundleActive)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusCABundlePath", multiMQTTClient_Instances[selectedInstance].parameters.caBundlePath)

    Script.notifyEvent("MultiMQTTClient_OnNewStatusInterfaceList", multiMQTTClient_Instances[selectedInstance].ethernetPortsList)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusInterface", multiMQTTClient_Instances[selectedInstance].parameters.interface)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusKeepAliveInterval", multiMQTTClient_Instances[selectedInstance].parameters.keepAliveInterval)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusUseCredentials", multiMQTTClient_Instances[selectedInstance].parameters.useCredentials)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusUsername", multiMQTTClient_Instances[selectedInstance].parameters.username)

    Script.notifyEvent("MultiMQTTClient_OnNewStatusForwardReceivedMsg", multiMQTTClient_Instances[selectedInstance].parameters.forwardReceives)

    Script.notifyEvent("MultiMQTTClient_OnNewStatusSubscriptionTopic", multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusSubscriptionQOS", multiMQTTClient_Instances[selectedInstance].tempSubscriptionQOS)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusSubscriptionList", multiMQTTClient_Instances[selectedInstance].helperFuncs.createJsonListSubscriptions(multiMQTTClient_Instances[selectedInstance].parameters.subscriptions, multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic))
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishEventList", multiMQTTClient_Instances[selectedInstance].helperFuncs.createJsonListPublishEvents(multiMQTTClient_Instances[selectedInstance].parameters.publishEvents, multiMQTTClient_Instances[selectedInstance].tempPublishEvent))

    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishEventName", multiMQTTClient_Instances[selectedInstance].tempPublishEvent)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishTopic", multiMQTTClient_Instances[selectedInstance].tempPublishTopic)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishData", multiMQTTClient_Instances[selectedInstance].tempPublishData)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishQOS", multiMQTTClient_Instances[selectedInstance].tempPublishQOS)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishRetain", multiMQTTClient_Instances[selectedInstance].tempPublishRetain)

    Script.notifyEvent("MultiMQTTClient_OnNewStatusWillMessageActive", multiMQTTClient_Instances[selectedInstance].parameters.useWillMessage)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusDisconnectWithWillMessage", multiMQTTClient_Instances[selectedInstance].parameters.disconnectWithWillMessage)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusWillMessageConfig", "Topic = '" .. multiMQTTClient_Instances[selectedInstance].parameters.willMessageTopic ..
                                                                  "', Data = '" .. multiMQTTClient_Instances[selectedInstance].parameters.willMessageData ..
                                                                  "', QoS = '" .. multiMQTTClient_Instances[selectedInstance].parameters.willMessageQOS ..
                                                                  "', Retain = '" .. multiMQTTClient_Instances[selectedInstance].parameters.willMessageRetain)

    Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'sendLog')

    Script.notifyEvent("MultiMQTTClient_OnNewStatusLoadParameterOnReboot", multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiMQTTClient_OnPersistentDataModuleAvailable", multiMQTTClient_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiMQTTClient_OnNewParameterName", multiMQTTClient_Instances[selectedInstance].parametersName)

    Script.notifyEvent("MultiMQTTClient_OnNewStatusLoadParameterOnReboot", multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiMQTTClient_OnPersistentDataModuleAvailable", multiMQTTClient_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiMQTTClient_OnNewParameterName", multiMQTTClient_Instances[selectedInstance].parametersName)
  end
end
Timer.register(tmrMultiMQTTClient, "OnExpired", handleOnExpiredTmrMultiMQTTClient)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    updateUserLevel() -- try to hide user specific content asap
  end
  tmrMultiMQTTClient:start()
  return ''
end
Script.serveFunction("CSK_MultiMQTTClient.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  if #multiMQTTClient_Instances >= instance then
    selectedInstance = instance
    _G.logger:fine(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
    multiMQTTClient_Instances[selectedInstance].activeInUI = true
    Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
    tmrMultiMQTTClient:start()
  else
    _G.logger:warning(nameOfModule .. ": Selected instance does not exist.")
  end
end
Script.serveFunction("CSK_MultiMQTTClient.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  return #multiMQTTClient_Instances
end
Script.serveFunction("CSK_MultiMQTTClient.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:fine(nameOfModule .. ": Add instance")
  table.insert(multiMQTTClient_Instances, multiMQTTClient_Instances[selectedInstance].create(#multiMQTTClient_Instances+1))
  Script.deregister("CSK_MultiMQTTClient.OnNewValueToForward" .. tostring(#multiMQTTClient_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiMQTTClient.OnNewValueToForward" .. tostring(#multiMQTTClient_Instances) , handleOnNewValueToForward)

  Script.deregister("CSK_MultiMQTTClient.OnNewValueUpdate" .. tostring(#multiMQTTClient_Instances) , handleOnNewValueUpdate)
  Script.register("CSK_MultiMQTTClient.OnNewValueUpdate" .. tostring(#multiMQTTClient_Instances) , handleOnNewValueUpdate)
  handleOnExpiredTmrMultiMQTTClient()
end
Script.serveFunction('CSK_MultiMQTTClient.addInstance', addInstance)

local function resetInstances()
  _G.logger:fine(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiMQTTClient_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiMQTTClient_Instances[totalAmount])
    multiMQTTClient_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiMQTTClient()
end
Script.serveFunction('CSK_MultiMQTTClient.resetInstances', resetInstances)

--TODO
local function getMQTTHandle()
  return multiMQTTClient_Instances[selectedInstance].mqttClient
end
Script.serveFunction('CSK_MultiMQTTClient.getMQTTHandle', getMQTTHandle)

local function connectMQTT(status)
  _G.logger:fine(nameOfModule .. ": Set connection status of instance " .. tostring(selectedInstance) .. " to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.connect = status
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'connect', status)
end
Script.serveFunction('CSK_MultiMQTTClient.connectMQTT', connectMQTT)

local function setBrokerIP(ip)
  _G.logger:fine(nameOfModule .. ": Set IP to " .. ip)
  multiMQTTClient_Instances[selectedInstance].parameters.brokerIP = ip
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'brokerIP', ip)
end
Script.serveFunction('CSK_MultiMQTTClient.setBrokerIP', setBrokerIP)

local function setMQTTPort(port)
  _G.logger:fine(nameOfModule .. ": Set port to " .. tostring(port))
  multiMQTTClient_Instances[selectedInstance].parameters.brokerPort = port
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'brokerPort', port)
end
Script.serveFunction('CSK_MultiMQTTClient.setMQTTPort', setMQTTPort)

local function setForwardReceivedMessages(status)
  _G.logger:fine(nameOfModule .. ": Set status to forward received messages to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.forwardReceives = status
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'forwardReceives', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setForwardReceivedMessages', setForwardReceivedMessages)

local function setConnectionTimeout(time)
  _G.logger:fine(nameOfModule .. ": Set connection timeout to " .. tostring(time) .. "ms.")
  multiMQTTClient_Instances[selectedInstance].parameters.connectionTimeout = time
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'connectionTimeout', time)
end
Script.serveFunction('CSK_MultiMQTTClient.setConnectionTimeout', setConnectionTimeout)

local function setClientID(id)
  _G.logger:fine(nameOfModule .. ": Set client ID to '" .. id .. "'")
  multiMQTTClient_Instances[selectedInstance].parameters.mqttClientID = id
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'mqttClientID', id)
end
Script.serveFunction('CSK_MultiMQTTClient.setClientID', setClientID)

local function setTLSVersion(version)
  _G.logger:fine(nameOfModule .. ": Set TLS version to '" .. version .. "'")
  multiMQTTClient_Instances[selectedInstance].parameters.tlsVersion = version
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'tlsVersion', version)
end
Script.serveFunction('CSK_MultiMQTTClient.setTLSVersion', setTLSVersion)

--- Function to check if TLS is activated
local function checkTLS()
  if multiMQTTClient_Instances[selectedInstance].parameters.tlsVersion == 'NO_TLS' then
    -- TLS needs to be activated if hostname verification should be active
    setTLSVersion('TLS_V12')
    Script.notifyEvent("MultiMQTTClient_OnNewStatusTLS", multiMQTTClient_Instances[selectedInstance].parameters.tlsVersion)
  end
end

local function setHostnameVerification(status)
  _G.logger:fine(nameOfModule .. ": Set hostname verification to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.hostnameVerification = status
  if status == true then
    checkTLS()
  end
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'hostnameVerification', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setHostnameVerification', setHostnameVerification)

local function setInterface(interface)
  _G.logger:fine(nameOfModule .. ": Set interface to " .. interface)
  multiMQTTClient_Instances[selectedInstance].parameters.interface = interface
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'interface', interface)
end
Script.serveFunction('CSK_MultiMQTTClient.setInterface', setInterface)

local function setKeepAliveInterval(time)
  _G.logger:fine(nameOfModule .. ": Set keep alive interval to " .. tostring(time))
  multiMQTTClient_Instances[selectedInstance].parameters.keepAliveInterval = time
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'keepAliveInterval', time)
end
Script.serveFunction('CSK_MultiMQTTClient.setKeepAliveInterval', setKeepAliveInterval)

local function setUsername(username)
  _G.logger:fine(nameOfModule .. ": Set username to '" .. username .. "'")
  multiMQTTClient_Instances[selectedInstance].parameters.username = username
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'username', username)
end
Script.serveFunction('CSK_MultiMQTTClient.setUsername', setUsername)

local function setPassword(password)
  _G.logger:fine(nameOfModule .. ": Set password.")
  local encryptedPassword = Cipher.AES.encrypt(password, multiMQTTClient_Instances[selectedInstance].key)
  multiMQTTClient_Instances[selectedInstance].parameters.passwords = encryptedPassword
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'passwords', encryptedPassword)
end
Script.serveFunction('CSK_MultiMQTTClient.setPassword', setPassword)

local function setUseCredentials(status)
  _G.logger:fine(nameOfModule .. ": Set usage of credentials to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.useCredentials = status
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'useCredentials', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setUseCredentials', setUseCredentials)

local function setCleanSession(status)
  _G.logger:fine(nameOfModule .. ": Set status of Clean Session to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.cleanSession = status
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'cleanSession', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setCleanSession', setCleanSession)

local function setPeerVerification(status)
  _G.logger:fine(nameOfModule .. ": Set peer verification to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.peerVerification = status
  if status == true then
    checkTLS()
  end
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'peerVerification', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setPeerVerification', setPeerVerification)

local function setUseClientCertificate(status)
  _G.logger:fine(nameOfModule .. ": Set status to use client certificate to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateActive = status
  if status == true then
    checkTLS()
  end
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificateActive', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setUseClientCertificate', setUseClientCertificate)

local function setClientCertificatePath(path)
  _G.logger:fine(nameOfModule .. ": Set path to client certificate to '" .. path .. "'")
  multiMQTTClient_Instances[selectedInstance].parameters.clientCertificatePath = path
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificatePath', path)
end
Script.serveFunction('CSK_MultiMQTTClient.setClientCertificatePath', setClientCertificatePath)

local function setClientCertificateKeyPath(path)
  _G.logger:fine(nameOfModule .. ": Set path to client certificate key to '" .. path .. "'")
  multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateKeyPath = path
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificateKeyPath', path)
end
Script.serveFunction('CSK_MultiMQTTClient.setClientCertificateKeyPath', setClientCertificateKeyPath)

local function setClientCertificateKeyPassword(password)
  _G.logger:fine(nameOfModule .. ": Set password for client certificate key.")
  if password == '' then
    multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateKeyPassword = ''
    Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificateKeyPassword', '')
  else
    local encryptedPassword = Cipher.AES.encrypt(password, multiMQTTClient_Instances[selectedInstance].key)
    multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateKeyPassword = encryptedPassword
    Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificateKeyPassword', encryptedPassword)
  end
end
Script.serveFunction('CSK_MultiMQTTClient.setClientCertificateKeyPassword', setClientCertificateKeyPassword)

local function setUseCABundle(status)
  _G.logger:fine(nameOfModule .. ": Set status to use CA bundle to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.caBundleActive = status
  if status == true then
    checkTLS()
  end
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'caBundleActive', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setUseCABundle', setUseCABundle)

local function setCABundlePath(path)
  _G.logger:fine(nameOfModule .. ": Set path to CA bundle to '" .. path .. "'")
  multiMQTTClient_Instances[selectedInstance].parameters.caBundlePath = path
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'caBundlePath', path)
end
Script.serveFunction('CSK_MultiMQTTClient.setCABundlePath', setCABundlePath)

---------------------------------------------------
------------------ Subscriptions ------------------
---------------------------------------------------

local function presetSubscriptionTopic(topic)
  multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic = topic
end
Script.serveFunction('CSK_MultiMQTTClient.presetSubscriptionTopic', presetSubscriptionTopic)

local function presetSubscriptionQOS(qos)
  multiMQTTClient_Instances[selectedInstance].tempSubscriptionQOS = qos
end
Script.serveFunction('CSK_MultiMQTTClient.presetSubscriptionQOS', presetSubscriptionQOS)

local function addSubscription(topicFilter, qos)
  _G.logger:fine(nameOfModule .. ": Add subcription to topic '" .. tostring(topicFilter) .. "' with QoS of '" .. tostring(qos) .. "'")
  multiMQTTClient_Instances[selectedInstance].parameters.subscriptions[topicFilter] = qos
  Script.notifyEvent("MultiMQTTClient_OnNewStatusSubscriptionList", multiMQTTClient_Instances[selectedInstance].helperFuncs.createJsonListSubscriptions(multiMQTTClient_Instances[selectedInstance].parameters.subscriptions, multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic))
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'subscribe', multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic, multiMQTTClient_Instances[selectedInstance].tempSubscriptionQOS)
end
Script.serveFunction('CSK_MultiMQTTClient.addSubscription', addSubscription)

local function addSubscriptionViaUI()
  addSubscription(multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic, multiMQTTClient_Instances[selectedInstance].tempSubscriptionQOS)
end
Script.serveFunction('CSK_MultiMQTTClient.addSubscriptionViaUI', addSubscriptionViaUI)

--- Function to check if selection in UIs DynamicTable can find related pattern
---@param selection string Full text of selection
---@param pattern string Pattern to search for
local function checkSelection(selection, pattern)
  if selection ~= "" then
    local _, pos = string.find(selection, pattern)
    if pos == nil then
    else
      pos = tonumber(pos)
      local endPos = string.find(selection, '"', pos+1)
      local tempSelection = string.sub(selection, pos+1, endPos-1)
      if tempSelection ~= nil and tempSelection ~= '-' then
        return tempSelection
      end
    end
  end
  return nil
end

local function selectSubscription(selection)
  local tempSelection = checkSelection(selection, '"DTC_SubTopic":"')
  if tempSelection ~= nil and tempSelection ~= '-' then
    multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic = tempSelection
    multiMQTTClient_Instances[selectedInstance].tempSubscriptionQOS = multiMQTTClient_Instances[selectedInstance].parameters.subscriptions[tempSelection]
    Script.notifyEvent("MultiMQTTClient_OnNewStatusSubscriptionTopic", multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusSubscriptionQOS", multiMQTTClient_Instances[selectedInstance].tempSubscriptionQOS)
  end
  Script.notifyEvent("MultiMQTTClient_OnNewStatusSubscriptionList", multiMQTTClient_Instances[selectedInstance].helperFuncs.createJsonListSubscriptions(multiMQTTClient_Instances[selectedInstance].parameters.subscriptions, multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic))
end
Script.serveFunction('CSK_MultiMQTTClient.selectSubscriptionViaUI', selectSubscription)

local function unsubscribe(topic)
  if multiMQTTClient_Instances[selectedInstance].parameters.subscriptions[topic] then
    _G.logger:fine(nameOfModule .. ": Unsubscribe from topic '" .. topic .. "'")
    multiMQTTClient_Instances[selectedInstance].parameters.subscriptions[topic] = nil
    Script.notifyEvent("MultiMQTTClient_OnNewStatusSubscriptionList", multiMQTTClient_Instances[selectedInstance].helperFuncs.createJsonListSubscriptions(multiMQTTClient_Instances[selectedInstance].parameters.subscriptions, multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic))

    Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'subscribe', topic)
  else
    _G.logger:info(nameOfModule .. ": Topic to unsubscribe not available: '" .. topic .. "'")
  end
end
Script.serveFunction('CSK_MultiMQTTClient.unsubscribe', unsubscribe)

local function unsubscribeViaUI()
  if multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic ~= '' then
    unsubscribe(multiMQTTClient_Instances[selectedInstance].tempSubscriptionTopic)
  end
end
Script.serveFunction('CSK_MultiMQTTClient.unsubscribeViaUI', unsubscribeViaUI)

---------------------------------------------
------------------ Publish ------------------
---------------------------------------------

local function presetPublishTopic(topic)
  multiMQTTClient_Instances[selectedInstance].tempPublishTopic = topic
end
Script.serveFunction('CSK_MultiMQTTClient.presetPublishTopic', presetPublishTopic)

local function presetPublishData(data)
  multiMQTTClient_Instances[selectedInstance].tempPublishData = data
end
Script.serveFunction('CSK_MultiMQTTClient.presetPublishData', presetPublishData)

local function presetPublishQOS(qos)
  multiMQTTClient_Instances[selectedInstance].tempPublishQOS = qos
end
Script.serveFunction('CSK_MultiMQTTClient.presetPublishQOS', presetPublishQOS)

local function presetPublishRetain(status)
  multiMQTTClient_Instances[selectedInstance].tempPublishRetain = status
end
Script.serveFunction('CSK_MultiMQTTClient.presetPublishRetain', presetPublishRetain)

local function publishViaUI()
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'publish', multiMQTTClient_Instances[selectedInstance].tempPublishTopic, multiMQTTClient_Instances[selectedInstance].tempPublishData, multiMQTTClient_Instances[selectedInstance].tempPublishQOS, multiMQTTClient_Instances[selectedInstance].tempPublishRetain)
end
Script.serveFunction('CSK_MultiMQTTClient.publishViaUI', publishViaUI)

local function presetPublishEvent(name)
  multiMQTTClient_Instances[selectedInstance].tempPublishEvent = name
end
Script.serveFunction('CSK_MultiMQTTClient.presetPublishEvent', presetPublishEvent)

--- Function to create internal publish functions
---@param event string Name of event to register (event with one parameter expected)
local function createInternalPublishFunctions(event)
  multiMQTTClient_Instances[selectedInstance].publishEventsFunctions[event] = true
end

local function addPublishEvent(event, topic, qos, retain)

  if multiMQTTClient_Instances[selectedInstance].publishEventsFunctions[event] then
    multiMQTTClient_Instances[selectedInstance].publishEventsFunctions[event] = nil
  end
  multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.topic[event] = topic
  multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.qos[event] = qos
  multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.retain[event] = retain

  Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishEventList", multiMQTTClient_Instances[selectedInstance].helperFuncs.createJsonListPublishEvents(multiMQTTClient_Instances[selectedInstance].parameters.publishEvents, multiMQTTClient_Instances[selectedInstance].tempPublishEvent))

  createInternalPublishFunctions(event)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'addPublishEvent', event, topic, qos, retain)
end
Script.serveFunction('CSK_MultiMQTTClient.addPublishEvent', addPublishEvent)

local function addPublishEventViaUI()
  if multiMQTTClient_Instances[selectedInstance].tempPublishEvent ~= '' then
    addPublishEvent(multiMQTTClient_Instances[selectedInstance].tempPublishEvent, multiMQTTClient_Instances[selectedInstance].tempPublishTopic, multiMQTTClient_Instances[selectedInstance].tempPublishQOS, multiMQTTClient_Instances[selectedInstance].tempPublishRetain)
  end
end
Script.serveFunction('CSK_MultiMQTTClient.addPublishEventViaUI', addPublishEventViaUI)

local function removePublishEvent(event)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'removePublishEvent', event)

  if multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.topic[event] then

    _G.logger:fine(nameOfModule .. ": Deregister from event '" .. event .. "' and remove this from the list.")
    multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.topic[event] = nil
    multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.qos[event] = nil
    multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.retain[event] = nil

    --Script.deregister(event, multiMQTTClient_Instances[selectedInstance].publishEventsFunctions[event])
    multiMQTTClient_Instances[selectedInstance].publishEventsFunctions[event] = nil

    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishEventList", multiMQTTClient_Instances[selectedInstance].helperFuncs.createJsonListPublishEvents(multiMQTTClient_Instances[selectedInstance].parameters.publishEvents, multiMQTTClient_Instances[selectedInstance].tempPublishEvent))
  else

    _G.logger:info(nameOfModule .. ": Not possible to deregister from event '" .. event .. "'.")
  end
end
Script.serveFunction('CSK_MultiMQTTClient.removePublishEvent', removePublishEvent)

local function removePublishEventViaUI()
  removePublishEvent(multiMQTTClient_Instances[selectedInstance].tempPublishEvent)
end
Script.serveFunction('CSK_MultiMQTTClient.removePublishEventViaUI', removePublishEventViaUI)

local function selectPublishEvent(selection)
  local tempSelection = checkSelection(selection, '"DTC_Event":"')
  if tempSelection ~= nil and tempSelection ~= '-' then
    multiMQTTClient_Instances[selectedInstance].tempPublishEvent = tempSelection
    multiMQTTClient_Instances[selectedInstance].tempPublishTopic = multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.topic[tempSelection]
    multiMQTTClient_Instances[selectedInstance].tempPublishQOS = multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.qos[tempSelection]
    multiMQTTClient_Instances[selectedInstance].tempPublishRetain  = multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.retain[tempSelection]

    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishEventName", multiMQTTClient_Instances[selectedInstance].tempPublishEvent)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishTopic", multiMQTTClient_Instances[selectedInstance].tempPublishTopic)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishQOS", multiMQTTClient_Instances[selectedInstance].tempPublishQOS)
    Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishRetain", multiMQTTClient_Instances[selectedInstance].tempPublishRetain)
  end
  Script.notifyEvent("MultiMQTTClient_OnNewStatusPublishEventList", multiMQTTClient_Instances[selectedInstance].helperFuncs.createJsonListPublishEvents(multiMQTTClient_Instances[selectedInstance].parameters.publishEvents, multiMQTTClient_Instances[selectedInstance].tempPublishEvent))
end
Script.serveFunction('CSK_MultiMQTTClient.selectPublishEvent', selectPublishEvent)

local function setWillMessageActivation(status)
  _G.logger:fine(nameOfModule .. ": Set WillMessage activation to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.useWillMessage = status
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'useWillMessage', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setWillMessageActivation', setWillMessageActivation)

local function setDisconnectWithWillMessage(status)
  _G.logger:fine(nameOfModule .. ": Set DisconnectWithWillMessage to " .. tostring(status))
  multiMQTTClient_Instances[selectedInstance].parameters.disconnectWithWillMessage = status
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'disconnectWithWillMessage', status)
end
Script.serveFunction('CSK_MultiMQTTClient.setDisconnectWithWillMessage', setDisconnectWithWillMessage)

local function setWillMessageConfig(topic, data, qos, retain)
  _G.logger:fine(nameOfModule .. ": Set WillMessage config with data '" .. data .. "' to topic '" .. topic .. "' with QoS '" .. qos .. "' and '" .. retain .. "'")
  multiMQTTClient_Instances[selectedInstance].parameters.willMessageTopic = topic
  multiMQTTClient_Instances[selectedInstance].parameters.willMessageData = data
  multiMQTTClient_Instances[selectedInstance].parameters.willMessageQOS = qos
  multiMQTTClient_Instances[selectedInstance].parameters.willMessageRetain = retain

  Script.notifyEvent("MultiMQTTClient_OnNewStatusWillMessageConfig", "Topic = '" .. multiMQTTClient_Instances[selectedInstance].parameters.willMessageTopic ..
                                                             "', Data = '" .. multiMQTTClient_Instances[selectedInstance].parameters.willMessageData ..
                                                             "', QoS = '" .. multiMQTTClient_Instances[selectedInstance].parameters.willMessageQOS ..
                                                             "', Retain = '" .. multiMQTTClient_Instances[selectedInstance].parameters.willMessageRetain)

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'willMessageConfig', topic, data, qos, retain)

end
Script.serveFunction('CSK_MultiMQTTClient.setWillMessageConfig', setWillMessageConfig)

local function setWillMessageConfigViaUI()
  setWillMessageConfig(multiMQTTClient_Instances[selectedInstance].tempPublishTopic, multiMQTTClient_Instances[selectedInstance].tempPublishData, multiMQTTClient_Instances[selectedInstance].tempPublishQOS, multiMQTTClient_Instances[selectedInstance].tempPublishRetain)
end
Script.serveFunction('CSK_MultiMQTTClient.setWillMessageConfigViaUI', setWillMessageConfigViaUI)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_MultiMQTTClient.getStatusModuleActive', getStatusModuleActive)

local function getParameters()
  return multiMQTTClient_Instances[selectedInstance].helperFuncs.json.encode(multiMQTTClient_Instances[selectedInstance].parameters)
end
Script.serveFunction('CSK_MultiMQTTClient.getParameters', getParameters)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'brokerIP', multiMQTTClient_Instances[selectedInstance].parameters.brokerIP)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'brokerPort', multiMQTTClient_Instances[selectedInstance].parameters.brokerPort)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'interface', multiMQTTClient_Instances[selectedInstance].parameters.interface)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'connectionTimeout', multiMQTTClient_Instances[selectedInstance].parameters.connectionTimeout)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'cleanSession', multiMQTTClient_Instances[selectedInstance].parameters.cleanSession)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'mqttClientID', multiMQTTClient_Instances[selectedInstance].parameters.mqttClientID)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'tlsVersion', multiMQTTClient_Instances[selectedInstance].parameters.tlsVersion)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'peerVerification', multiMQTTClient_Instances[selectedInstance].parameters.peerVerification)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'hostnameVerification', multiMQTTClient_Instances[selectedInstance].parameters.hostnameVerification)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'useCredentials', multiMQTTClient_Instances[selectedInstance].parameters.useCredentials)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'username', multiMQTTClient_Instances[selectedInstance].parameters.username)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'passwords', multiMQTTClient_Instances[selectedInstance].parameters.passwords)

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificateKeyPath', multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateKeyPath)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificateKeyPassword', multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateKeyPassword)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificatePath', multiMQTTClient_Instances[selectedInstance].parameters.clientCertificatePath)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'clientCertificateActive', multiMQTTClient_Instances[selectedInstance].parameters.clientCertificateActive)

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'caBundlePath', multiMQTTClient_Instances[selectedInstance].parameters.caBundlePath)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'caBundleActive', multiMQTTClient_Instances[selectedInstance].parameters.caBundleActive)

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'disconnectWithWillMessage', multiMQTTClient_Instances[selectedInstance].parameters.disconnectWithWillMessage)

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'keepAliveInterval', multiMQTTClient_Instances[selectedInstance].parameters.keepAliveInterval)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'forwardReceives', multiMQTTClient_Instances[selectedInstance].parameters.forwardReceives)

  for key, value in pairs(multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.topic) do
    createInternalPublishFunctions(value)
    Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'addPublishEvent', key, multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.topic[key], multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.qos[key], multiMQTTClient_Instances[selectedInstance].parameters.publishEvents.retain[key])
  end

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'willMessageConfig', multiMQTTClient_Instances[selectedInstance].parameters.willMessageTopic, multiMQTTClient_Instances[selectedInstance].parameters.willMessageData, multiMQTTClient_Instances[selectedInstance].parameters.willMessageQOS, multiMQTTClient_Instances[selectedInstance].parameters.willMessageRetain)
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'useWillMessage', multiMQTTClient_Instances[selectedInstance].parameters.useWillMessage)

  for key, value in pairs(multiMQTTClient_Instances[selectedInstance].parameters.subscriptions) do
    Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'subscribe', key, value)
  end

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'connect', multiMQTTClient_Instances[selectedInstance].parameters.connect)
end

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiMQTTClient_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiMQTTClient.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if multiMQTTClient_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiMQTTClient_Instances[selectedInstance].parameters), multiMQTTClient_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiMQTTClient_Instances[selectedInstance].parametersName, multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiMQTTClient_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiMQTTClient_Instances[selectedInstance].parametersName, multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:fine(nameOfModule .. ": Send MultiMQTTClient parameters with name '" .. multiMQTTClient_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiMQTTClient.sendParameters", sendParameters)

local function loadParameters()
  if multiMQTTClient_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiMQTTClient_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiMQTTClientObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")

      Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'deregisterFromAllEvents')

      multiMQTTClient_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      tmrMultiMQTTClient:start()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      tmrMultiMQTTClient:start()
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    tmrMultiMQTTClient:start()
    return false
  end
end
Script.serveFunction("CSK_MultiMQTTClient.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("MultiMQTTClient_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_MultiMQTTClient.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then

    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

      for j = 1, #multiMQTTClient_Instances do
        multiMQTTClient_Instances[j].persistentModuleAvailable = false
      end
    else
      -- Check if CSK_PersistentData version is >= 3.0.0
      if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
        local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
        -- Check for amount if instances to create
        if totalInstances then
          local c = 2
          while c <= totalInstances do
            addInstance()
            c = c+1
          end
        end
      end

      for i = 1, #multiMQTTClient_Instances do
        local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

        if parameterName then
          multiMQTTClient_Instances[i].parametersName = parameterName
          multiMQTTClient_Instances[i].parameterLoadOnReboot = loadOnReboot
        end

        if multiMQTTClient_Instances[i].parameterLoadOnReboot then
          setSelectedInstance(i)
          loadParameters()
        end
      end
      Script.notifyEvent('MultiMQTTClient_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    --clearFlowConfigRelevantConfiguration()
    pageCalled()
  end
end
Script.serveFunction('CSK_MultiMQTTClient.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

