local activeGuids = {}
local oldPrint = print

function betterPrint(msg)
	local guid = game:GetService("HttpService"):GenerateGUID(false)
	oldPrint(guid)
	if typeof(msg) == "table" then
		msg = game:GetService("HttpService"):JSONEncode(msg)
	end
	activeGuids[guid] = {
		Text = msg;
		Color = Color3.fromRGB(255, 255, 255);
		TextTransparency = 0;
		Visible = true;
		Image = "";
	}
	local obj = {} --Taken from this cat: https://v3rm.net/threads/customizable-print-function.25491/
	function obj:updateText(newText)
		activeGuids[guid].Text = newText
		return obj
	end
	function obj:setColor(color3)
		activeGuids[guid].Color = color3
		return obj
	end
	function obj:setTransparency(alpha)
		activeGuids[guid].TextTransparency = alpha
		return obj
	end
	function obj:setVisible(state)
		activeGuids[guid].Visible = state
		return obj
	end
	function obj:getText()
		return activeGuids[guid].Text
	end
	function obj:setImage(asset)
		activeGuids[guid].Image = asset
	end
	return obj
end

shared.print = betterPrint
_G.print = betterPrint
print = betterPrint
if getgenv then getgenv().print = betterPrint end

print("[PRINT+]: LOADED CONSOLE"):setColor(Color3.fromRGB(255, 100, 255)):setImage("rbxassetid://90507639872505")

task.spawn(function() --I cannot come up with any better way of doing this.
	while true do
		task.wait()
		local ClientLog = nil
		pcall(function() --Whenever i closed developer console it deleted the whole ClientLog
			ClientLog = game:GetService("CoreGui").DevConsoleMaster.DevConsoleWindow.DevConsoleUI.MainView.ClientLog
		end)
		if ClientLog and ClientLog.Parent then
			for guid, data in pairs(activeGuids) do
				for _, v in ipairs(ClientLog:GetChildren()) do
					local lebel = v:FindFirstChild("msg") :: TextLabel
					if lebel and lebel:IsA("TextLabel") and (lebel.Text:find(guid, 11, true) or (lebel:GetAttribute("guid") and lebel:GetAttribute("guid") == guid)) then
						if not lebel:GetAttribute("guid") then lebel:SetAttribute("guid", guid) end
						if not rawget(data, "Text") then data.Text = "Forgot text? use msg:updateText('new text')" end
						lebel.Text = data.Text
						if rawget(data, "Color") then lebel.TextColor3 = data.Color end
						if rawget(data, "Visible") then lebel.Visible = data.Visible end
						if rawget(data, "TextTransparency") then lebel.TextTransparency = data.TextTransparency end
						if rawget(data, "Image") and v:FindFirstChild("image") then pcall(function() v.image.Image = data.Image end) end
						break
					end
				end
			end
		end
	end
end)

return betterPrint
