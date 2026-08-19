--!nonstrict

noctalia.setUpdateInterval(1e8) -- Never please

local DIRECTIONS = {"left", "all", "right", "position"}

local direction: "left" | "all" | "right" | "position" = noctalia.getConfig("direction")

local index
for i = 1, #DIRECTIONS do
	if DIRECTIONS[i] == direction then
		index = i
		break
	end
end

local last
noctalia.state.watch("data", function(data)
	local text = string.split(data, ",")[index]
	if text == last then return end
	last = text
	barWidget.setText(text)
end)
