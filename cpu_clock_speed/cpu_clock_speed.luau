--!nonstrict

local glyph = barWidget.getConfig("glyph")
local showGlyph = barWidget.getConfig("show_glyph")

local label = "???"

function render()
  if showGlyph then
      barWidget.setGlyph(glyph)
  end
  barWidget.setText(label)
end

function updateInfo()
  local contents, error = noctalia.readFile("/proc/cpuinfo")
  if error then
    label = error
    return
  end
  local maxFreq = 0
  local cpuFound = false
  for line in contents:gmatch("[^\n]+") do
      if line:sub(1, 7) == "cpu MHz" then
        local freq = line:match("([%d%.]+)%s*$")
        if freq then
          freq = tonumber(freq)
          maxFreq = math.max(freq, maxFreq)
          cpuFound = true
        end
      end
  end
  if cpuFound then
    label = string.format("%.2f", maxFreq / 1000)
  else
    label = "No CPUs"
  end
end

function update()
  updateInfo()
  render()
end
