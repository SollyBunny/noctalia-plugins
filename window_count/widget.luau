--!nonstrict

-- noctalia.setUpdateInterval(1000)

-- local glyph = barWidget.getConfig("glyph")
-- local showGlyph = barWidget.getConfig("show_glyph")

-- local label = "???"

function render()
  -- if showGlyph then
  --     barWidget.setGlyph(glyph)
  -- end
  barWidget.setText("temp")
end

function update()
  render()
end
