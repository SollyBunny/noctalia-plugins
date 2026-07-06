--!nonstrict

noctalia.setUpdateInterval(1e8) -- Never please

local DIRECTIONS = {"Left", "All", "Right", "Position"}

local direction: "Left" | "All" | "Right" | "Position" = barWidget.getConfig("direction")

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
