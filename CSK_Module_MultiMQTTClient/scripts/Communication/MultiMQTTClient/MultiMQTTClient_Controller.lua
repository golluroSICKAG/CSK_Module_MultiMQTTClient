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

Script.serveEvent("CSK_MultiMQTTClient.OnNewResultNUM", "MultiMQTTClient_OnNewResultNUM")
Script.serveEvent("CSK_MultiMQTTClient.OnNewValueToForwardNUM", "MultiMQTTClient_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiMQTTClient.OnNewValueUpdateNUM", "MultiMQTTClient_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
-- Script.serveEvent("CSK_MultiMQTTClient.OnNewEvent", "MultiMQTTClient_OnNewEvent")
Script.serveEvent('CSK_MultiMQTTClient.OnNewResult', 'MultiMQTTClient_OnNewResult')

Script.serveEvent('CSK_MultiMQTTClient.OnNewStatusRegisteredEvent', 'MultiMQTTClient_OnNewStatusRegisteredEvent')

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

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

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
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    multiMQTTClient_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
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
  -- Script.notifyEvent("MultiMQTTClient_OnNewEvent", false)

  updateUserLevel()

  Script.notifyEvent('MultiMQTTClient_OnNewSelectedInstance', selectedInstance)
  Script.notifyEvent("MultiMQTTClient_OnNewInstanceList", helperFuncs.createStringListBySize(#multiMQTTClient_Instances))

  Script.notifyEvent("MultiMQTTClient_OnNewStatusRegisteredEvent", multiMQTTClient_Instances[selectedInstance].parameters.registeredEvent)

  Script.notifyEvent("MultiMQTTClient_OnNewStatusLoadParameterOnReboot", multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot)
  Script.notifyEvent("MultiMQTTClient_OnPersistentDataModuleAvailable", multiMQTTClient_Instances[selectedInstance].persistentModuleAvailable)
  Script.notifyEvent("MultiMQTTClient_OnNewParameterName", multiMQTTClient_Instances[selectedInstance].parametersName)

  -- ...
end
Timer.register(tmrMultiMQTTClient, "OnExpired", handleOnExpiredTmrMultiMQTTClient)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrMultiMQTTClient:start()
  return ''
end
Script.serveFunction("CSK_MultiMQTTClient.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  selectedInstance = instance
  _G.logger:info(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
  multiMQTTClient_Instances[selectedInstance].activeInUI = true
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  tmrMultiMQTTClient:start()
end
Script.serveFunction("CSK_MultiMQTTClient.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  return #multiMQTTClient_Instances
end
Script.serveFunction("CSK_MultiMQTTClient.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:info(nameOfModule .. ": Add instance")
  table.insert(multiMQTTClient_Instances, multiMQTTClient_Model.create(#multiMQTTClient_Instances+1))
  Script.deregister("CSK_MultiMQTTClient.OnNewValueToForward" .. tostring(#multiMQTTClient_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiMQTTClient.OnNewValueToForward" .. tostring(#multiMQTTClient_Instances) , handleOnNewValueToForward)
  handleOnExpiredTmrMultiMQTTClient()
end
Script.serveFunction('CSK_MultiMQTTClient.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
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

local function setRegisterEvent(event)
  multiMQTTClient_Instances[selectedInstance].parameters.registeredEvent = event
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
end
Script.serveFunction("CSK_MultiMQTTClient.setRegisterEvent", setRegisterEvent)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)

  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiMQTTClient_Instances[selectedInstance].parameters.registeredEvent)

  --Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'value', multiMQTTClient_Instances[selectedInstance].parameters.value)

  -- optionally for internal objects...
  --[[
  -- Send config to instances
  local params = helperFuncs.convertTable2Container(multiMQTTClient_Instances[selectedInstance].parameters.internalObject)
  Container.add(data, 'internalObject', params, 'OBJECT')
  Script.notifyEvent('MultiMQTTClient_OnNewProcessingParameter', selectedInstance, 'FullSetup', data)
  ]]

end

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiMQTTClient_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiMQTTClient.setParameterName", setParameterName)

local function sendParameters()
  if multiMQTTClient_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiMQTTClient_Instances[selectedInstance].parameters), multiMQTTClient_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiMQTTClient_Instances[selectedInstance].parametersName, multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiMQTTClient_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiMQTTClient_Instances[selectedInstance].parametersName, multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:info(nameOfModule .. ": Send MultiMQTTClient parameters with name '" .. multiMQTTClient_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
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
      multiMQTTClient_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      CSK_MultiMQTTClient.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
  tmrMultiMQTTClient:start()
end
Script.serveFunction("CSK_MultiMQTTClient.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiMQTTClient_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiMQTTClient.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
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
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

