--!nonstrict

noctalia.setUpdateInterval(1e8) -- Never please

noctalia.runStream(`node "{noctalia.pluginDir()}/service.mjs"`, function(line)
	noctalia.state.set("data", line)
end)
