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
      sorting_hint = "tools",
      callback = function()
	 local handle_efbpad = io.popen("/mnt/onboard/.adds/efbpad/bin/efbpad.sh 2>&1")
	 handle_efbpad:flush()
	 local str_efbpad = handle_efbpad:read("*all")
	 local retval_efbpad = handle_efbpad:close()
	 
	 local str_log = "/tmp/efbpad.log"
	 local file_log = io.open(str_log, "w")
	 file_log:write(str_efbpad)
	 io.close(file_log)

	 local n_log_bytes = string.len(str_efbpad)
	 local n_print_bytes = math.min(n_log_bytes, 100)
	 local str_msg = 
            tostring(n_log_bytes) .. " bytes written to " .. str_log .. ".\n" ..
            "Good return: " .. tostring(retval_efbpad) .. ".\n" ..
            "Output: [...]" .. str_efbpad:sub(-n_print_bytes)
	 UIManager:show(InfoMessage:new{
			   text = str_msg,
	 })
      end,
   }
end

return Efbpad
