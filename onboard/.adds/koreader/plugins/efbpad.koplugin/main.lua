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
			local retval_efbpad = handle_efbpad:close()

			local fname_log = "/tmp/efbpad/efbpad.log"
			local str_msg = ""
			local file_log = io.open(fname_log, "r")
			if(file_log ~= nil) then
				str_log = file_log:read("all*")
				io.close(file_log)

				str_msg = 
				"Good return: " .. tostring(retval_efbpad) .. ".\n" ..
				tostring(string.len(str_log)) .. " bytes written to " .. fname_log .. ":\n" ..
				"[...]" .. str_log:sub(-math.min(string.len(str_log), 100))
			else
				str_msg = 
				"Good return: " .. tostring(retval_efbpad) .. ".\n" ..
				"No log found."
			end

			UIManager:show(InfoMessage:new{
				text = str_msg,
			})
		end,
	}
end

return Efbpad
