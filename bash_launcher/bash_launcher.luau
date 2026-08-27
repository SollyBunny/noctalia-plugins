--!nonstrict

noctalia.setUpdateInterval(1e9) -- never please

local terminalCommand = noctalia.getConfig("terminal_command")

local function replaceLastWord(s, word)
	if s:sub(-1) == " " then return s .. word end
	local lastSpace = s:find("%s+%S+$")
	if lastSpace then return s:sub(1, lastSpace - 1) .. " " .. word end
	return word
end

local function getLastWord(s)
	if s:sub(-1) == " " then
		return s:match("(%S+)%s+%S*%s*$")
	else
		return s:match("(%S+)%s*$")
	end
end

local function startsWith(s, prefix)
	return s:sub(1, #prefix) == prefix
end

function setLauncherError(query, error)
	launcher.setResults(query, {
		{ id = "", title = "Error", subtitle = error, glyph = "toast-error" }
	})
end

function notifyError(error)
	noctalia.notifyError("Bash Launcher", error)
end

local inputpath = "/tmp/aurelia_launcher_bash"
noctalia.runAsync("mktemp \"${XDG_RUNTIME_DIR:-/tmp}/aurelia_launcher_bash.XXXXXX\"", function(result: CommandResult)
	inputpath = result.stdout
end, 100)

local excluded = {
	[","] = true,
	["}"] = true,
	["{"] = true,
	["[["] = true,
	["]]"] = true,
	["!"] = true,
	["["] = true,
	["]"] = true,
	[":"] = true,
	["."] = true,
	[".."] = true,
}

function onQuery(query)
	if #query < 1 then
		launcher.setResults(query, {
			{ id = "t/", title = "Open terminal" }
		})
		return
	end
	local _, err = noctalia.writeFile(inputpath, query)
	if err ~= nil then
		setLauncherError(query, `Failed to write to "{inputpath}"`)
		return
	end
	launcher.setResults(query, {
		{ id = "", title = "Loading", glyph = "reload" }
	})
	noctalia.runAsync(`cat "{inputpath}" | "{noctalia.pluginDir()}/fake_complete.bash"`, function(result: CommandResult)
		if result.timedOut then
			setLauncherError(query, `Completion for "{query}" timed out`)
			return
		elseif result.exitCode ~= 0 then
			setLauncherError(query, `Completion for "{query}" gave non zero exit code: {result.exitCode}`)
			return
		end

		local results = {}
		table.insert(results, { id = "/" .. query, title = query, subtitle = "No completion", glyph = "brand-tabler" })
		table.insert(results, { id = "t/" .. query, title = query, subtitle = "Run in terminal" })

		local lastWord = getLastWord(query)
		local lastWordUnderscored = startsWith(lastWord, "_")

		local count = 0
		for completion in result.stdout:gmatch("[^\n]*") do
			if #completion < 1 then continue end
			if completion == query then continue end
			if excluded[completion] then continue end
			if not lastWordUnderscored and startsWith(completion, "_") then continue end

			table.insert(results, {
				id = count,
				title = completion,
				query = replaceLastWord(query, completion) .. " ",
				glyph = "minus"
			})

			count += 1
			if count >= 100 then break end
		end

		launcher.setResults(query, results)
	end, 1000)
end

function onActivate(id)
	if #id < 1 then return end
	local mode, command = id:match("^([^/]*)/(.*)$")
	if mode == "t" then
		local _, err = noctalia.writeFile(inputpath, command)
		if err ~= nil then
			notifyError(`Failed to write to "{inputpath}"`)
			return
		end

		noctalia.runAsync(terminalCommand:gsub("$SCRIPT", inputpath), function(result: CommandResult)
			if result.timedOut then
				notifyError("Running command with terminal timed out")
			elseif result.exitCode ~= 0 then
				notifyError(`Running command with terminal gave non zero exit code: {result.exitCode}`)
			end
		end, 100)
	else
		noctalia.runAsync(command, function(result: CommandResult)
			if result.timedOut then
				notifyError("Running command timed out")
			elseif result.exitCode ~= 0 then
				notifyError(`Running command gave non zero exit code: {result.exitCode}`)
			end
		end, 1500)
	end
end
