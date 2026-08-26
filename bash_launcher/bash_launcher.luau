--!nonstrict

noctalia.setUpdateInterval(1e9) -- never please

local function replaceLastWord(s, word)
	local endSpace = s:match("%s+$")
	if endSpace then return s .. word end
	local lastSpace = s:find("%s+%S+$")
	if lastSpace then return s:sub(1, lastSpace - 1) .. word end
	return word
end

local inputpath = "/tmp/aurelia_launcher_bash"
noctalia.runAsync("mktemp \"${XDG_RUNTIME_DIR:-/tmp}/aurelia_launcher_bash.XXXXXX\"", function(result: CommandResult)
	inputpath = result.stdout
end, 100)

function onQuery(query)
	local _, err = noctalia.writeFile(inputpath, query)
	if err ~= nil then
		launcher.setResults(query, {
			{ id = "", title = "Error writing query", subtitle = err }
		})
		return
	end
	noctalia.runAsync(`cat "{inputpath}" | "{noctalia.pluginDir()}/fake_complete.bash"`, function(result: CommandResult)
		local out = {}
		table.insert(out, { id = query, title = query, subtitle = "No completion" })
		for completion in result.stdout:gmatch("[^\n]*") do
			if #completion < 1 then continue end
			if completion == query then continue end
			table.insert(out, { id = replaceLastWord(query, completion), title = completion })
		end
		launcher.setResults(query, out)
	end, 500)
end

function onActivate(id)
	noctalia.runInTerminal(id)
end
