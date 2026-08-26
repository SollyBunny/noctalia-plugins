--!nonstrict

noctalia.setUpdateInterval(1e9) -- never please

const tmppath = noctalia.runInTerminal("mktemp -d \"${XDG_RUNTIME_DIR:-/tmp}/aurelia_launcher_bash.XXXXXX\"")

function onQuery(query)
	local out = {}
	const inputpath = `{tmppath}/fake_complete_input.txt`
	noctalia.writeFile(inputpath, query)
	const lines = noctalia.runInTerminal(`cat "{inputpath}" | ./"{noctalia.pluginDir()}/fake_complete.bash"`);
	for line in lines:gmatch("[^\n]*") do
		table.insert(out, { id = line, title = line })
	end
	launcher.setResults(query, out)
end

function onActive(id)

end
