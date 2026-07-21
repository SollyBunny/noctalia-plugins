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

noctalia.state.watch("data", function(data)
	barWidget.setText(string.split(data, ",")[index])
end)
