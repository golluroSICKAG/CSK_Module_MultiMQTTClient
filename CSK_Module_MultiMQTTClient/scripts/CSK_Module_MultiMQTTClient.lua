--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection

_G.availableAPIs = require('Communication/MultiMQTTClient/helper/checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding MultiMQTTClient_Model
-- Check this script regarding MultiMQTTClient_Model parameters and functions
local multiMQTTClient_Model = require('Communication/MultiMQTTClient/MultiMQTTClient_Model')

local multiMQTTClient_Instances = {} -- Handle all instances

-- Load script to communicate with the MultiMQTTClient_Model UI
-- Check / edit this script to see/edit functions which communicate with the UI
local multiMQTTClientController = require('Communication/MultiMQTTClient/MultiMQTTClient_Controller')

if _G.availableAPIs.default and _G.availableAPIs.specific then
  table.insert(multiMQTTClient_Instances, multiMQTTClient_Model.create(1)) -- Create at least 1 instance
  multiMQTTClientController.setMultiMQTTClient_Instances_Handle(multiMQTTClient_Instances) -- share handle of instances
else
  _G.logger:warning("CSK_MultiColorSelection: Relevant CROWN(s) not available on device. Module is not supported...")
end

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function main()

  multiMQTTClientController.setMultiMQTTClient_Model_Handle(multiMQTTClient_Model) -- share handle of Model

  ----------------------------------------------------------------------------------------
  -- INFO: Please check if module will eventually load inital configuration triggered via
  --       event CSK_PersistentData.OnInitialDataLoaded
  --       (see internal variable _G.multiMQTTClient_Model.parameterLoadOnReboot)
  --       If so, the app will trigger the "OnDataLoadedOnReboot" event if ready after loading parameters
  --
  -- Can be used e.g. like this
  --[[

  CSK_MultiMQTTClient.setSelectedInstance(1)
  CSK_MultiMQTTClient.setBrokerIP('192.168.0.202')
  CSK_MultiMQTTClient.setMQTTPort(1883)
  CSK_MultiMQTTClient.connectMQTT(true)

  CSK_MultiMQTTClient.presetSubscriptionTopic('test/topic')
  CSK_MultiMQTTClient.presetSubscriptionQOS('QOS0')
  CSK_MultiMQTTClient.addSubscriptionViaUI()
  -- OR
  CSK_MultiMQTTClient.addSubscription('test/topic', 'QOS0')

  --------------------------------------------------------

  CSK_MultiMQTTClient.presetPublishTopic('test/topic')
  CSK_MultiMQTTClient.presetPublishQOS('QOS0')
  CSK_MultiMQTTClient.presetPublishRetain('NO_RETAIN')

  CSK_MultiMQTTClient.presetPublishData("Hello")
  CSK_MultiMQTTClient.publishViaUI()
  -- OR
  CSK_MultiMQTTClient.publish('test/topic', "Hello", 'QOS0', 'NO_RETAIN')

  --------------------------------------------------------

  CSK_MultiMQTTClient.presetPublishEvent('CSK_OtherModule.OnNewResult')
  CSK_MultiMQTTClient.addPublishEventViaUI()
  -- OR
  CSK_MultiMQTTClient.addPublishEvent('CSK_OtherModule.OnNewResult', 'test/topic', 'QOS0', 'NO_RETAIN')
]]
  --------------------------------------------------------
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    CSK_MultiMQTTClient.setSelectedInstance(1)
  end
  CSK_MultiMQTTClient.pageCalled() -- Update UI

end
Script.register("Engine.OnStarted", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************