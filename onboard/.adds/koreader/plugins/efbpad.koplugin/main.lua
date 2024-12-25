--[[--
   Launch efbpad
   @module koplugin.Efbpad
--]]--

require "io"
local Dispatcher = require("dispatcher")  -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

local Efbpad = WidgetContainer:extend{
   name = "efbpad",
   is_doc_only = false,
}

function Efbpad:init()
   self.ui.menu:registerToMainMenu(self)
end

function Efbpad:addToMainMenu(menu_items)
   menu_items.efbpad = {
      text = _("efbpad"),
      sorting_hint = "more_tools",
      callback = function()
	 err = io.popen("/mnt/onboard/.adds/efbpad/bin/efbpad.sh 2>&1")
	 if(err == nil or err == '') then
	    UIManager:show(InfoMessage:new{text = _("Efbpad ran successfully.")})
	 else
	    UIManager:show(InfoMessage:new{text=err})
	 end
      end,
   }
end

return Efbpad
