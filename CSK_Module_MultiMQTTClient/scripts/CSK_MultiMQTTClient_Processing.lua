---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
-- local availableAPIs = require('Mainfolder/Subfolder/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiMQTTClient'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiMQTTClientInstanceNumber = scriptParams:get('multiMQTTClientInstanceNumber') -- number of this instance
local multiMQTTClientInstanceNumberString = tostring(multiMQTTClientInstanceNumber) -- number of this instance as string
--local viewerId = scriptParams:get('viewerId')
--local viewer = View.create(viewerId) --> if needed
-- e.g. local object = MachineLearning.DeepNeuralNetwork.create() -- Use any AppEngine CROWN needed

-- Event to notify result of processing
Script.serveEvent("CSK_MultiMQTTClient.OnNewResult" .. multiMQTTClientInstanceNumberString, "MultiMQTTClient_OnNewResult" .. multiMQTTClientInstanceNumberString, 'bool') -- Edit this accordingly
-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiMQTTClient.OnNewValueToForward".. multiMQTTClientInstanceNumberString, "MultiMQTTClient_OnNewValueToForward" .. multiMQTTClientInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiMQTTClient.OnNewValueUpdate" .. multiMQTTClientInstanceNumberString, "MultiMQTTClient_OnNewValueUpdate" .. multiMQTTClientInstanceNumberString, 'int, string, auto, int:?')

local processingParams = {}
processingParams.registeredEvent = scriptParams:get('registeredEvent')
processingParams.activeInUI = false
--processingParams.showImage = scriptParams:get('showImage') -- if needed

-- optionally
--[[
local function setAllProcessingParameters(paramContainer)
  processingParams.paramA = paramContainer:get('paramA')
  processingParams.paramB = paramContainer:get('paramB')
  processingParams.selectedObject = paramContainer:get('selectedObject')

  -- ...

  processingParams.internalObjects = helperFuncs.convertContainer2Table(paramContainer:get('internalObjects'))

end
setAllProcessingParameters(scriptParams)
]]

local function handleOnNewProcessing(object)

  _G.logger:info(nameOfModule .. ": Check object on instance No." .. multiMQTTClientInstanceNumberString)

  -- Insert processing part
  -- E.g.
  --[[

  local result = someProcessingFunctions(object)

  Script.notifyEvent("MultiMQTTClient_OnNewValueUpdate" .. multiMQTTClientInstanceNumberString, multiMQTTClientInstanceNumber, 'valueName', result, processingParams.selectedObject)

  if processingParams.showImage and processingParams.activeInUI then
    viewer:addImage(image)
    viewer:present("LIVE")
  end
  ]]

  --_G.logger:info(nameOfModule .. ": Processing on MultiMQTTClient" .. multiMQTTClientInstanceNumberString .. " was = " .. tostring(result))
  --Script.notifyEvent('MultiMQTTClient_OnNewResult'.. multiMQTTClientInstanceNumberString, true)

  --Script.notifyEvent("MultiMQTTClient_OnNewValueToForward" .. multiMQTTClientInstanceNumberString, 'MultiColorSelection_CustomEventName', 'content')

  Script.releaseObject(object)

end
Script.serveFunction("CSK_MultiMQTTClient.processInstance"..multiMQTTClientInstanceNumberString, handleOnNewProcessing, 'object:?:Alias', 'bool:?') -- Edit this according to this function

--- Function to handle updates of processing parameters from Controller
---@param multiMQTTClientNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param internalObjectNo int? Number of object
local function handleOnNewProcessingParameter(multiMQTTClientNo, parameter, value, internalObjectNo)

  if multiMQTTClientNo == multiMQTTClientInstanceNumber then -- set parameter only in selected script
    _G.logger:info(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiMQTTClientInstanceNo." .. tostring(multiMQTTClientNo) .. " to value = " .. tostring(value))

    --[[
    if internalObjectNo then
      _G.logger:info(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiMQTTClientInstanceNo." .. tostring(multiMQTTClientNo) .. " of internalObject No." .. tostring(internalObjectNo) .. " to value = " .. tostring(value))
      processingParams.internalObjects[internalObjectNo][parameter] = value

    elseif parameter == 'FullSetup' then
      if type(value) == 'userdata' then
        if Object.getType(value) == 'Container' then
            setAllProcessingParameters(value)
        end
      end

    -- further checks
    --elseif parameter == 'chancelEditors' then
    end

    else
    ]]

    if parameter == 'registeredEvent' then
      _G.logger:info(nameOfModule .. ": Register instance " .. multiMQTTClientInstanceNumberString .. " on event " .. value)
      if processingParams.registeredEvent ~= '' then
        Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
      end
      processingParams.registeredEvent = value
      Script.register(value, handleOnNewProcessing)

    -- elseif parameter == 'someSpecificParameter' then
    --   --Setting something special...
    --   processingParams.specificVariable = value
    --   --Do some more specific...

    else
      processingParams[parameter] = value
      --if  parameter == 'showImage' and value == false then
      --  viewer:clear()
      --  viewer:present()
      --end
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiMQTTClient.OnNewProcessingParameter", handleOnNewProcessingParameter)
