#!/bin/env node

import { spawn } from "node:child_process";

function runStream(command, onLine) {
	const child = spawn(command, { stdio: ["ignore", "pipe", "inherit"], shell: true });
	let buffer = "";
	child.stdout.on("data", data => {
		buffer += data.toString();
		let lines = buffer.split("\n");
		buffer = lines.pop();
		for (const line of lines)
			onLine(line);
	});
}

const DEBOUNCE_MS = 50;

const DIRECTIONS = [
	{
		name: "Left",
		format: count => count === 0 ? "" : `← ${count}`,
		counts: (focused, other) => other.x < focused.x,
	}, {
		name: "All",
		format: count => count === 0 ? "" : `${count}`,
		counts: () => true,
	}, {
		name: "Right",
		format: count => count === 0 ? "" : `${count} →`,
		counts: (focused, other) => other.x + other.width > focused.x + focused.width,
	}, {
		name: "Position",
		format: (count, total) => total === 0 ? "" : `#${count + 1}`,
		counts: (focused, other) => other.x < focused.x,
	}
];

let valuesOld = Buffer.alloc(4).fill(255);
let values = Buffer.alloc(4).fill(0);

function parseInfo({ allClients, allTags, focusedClient }) {
	let total = 0;
	values.fill(0);

	if (focusedClient) {
		const monitor = focusedClient.monitor;
		const tags = allTags
			.filter(v => v.monitor === monitor)
			.flatMap(v => v.tags.filter(v => v.is_active))
			.map(v => v.index);

		for (const client of allClients) {
			if (client.monitor !== monitor || client.is_focused)
				continue;
			if (client.tags.find(v => tags.includes(v)) === undefined)
				continue;
			for (let i = 0; i < values.length; ++i)
				values[i] += DIRECTIONS[i].counts(focusedClient, client);
			total += 1;
		}
	}

	if (valuesOld.equals(values))
		return;

	let out = "";
	for (let i = 0; i < values.length; ++i)
		out += DIRECTIONS[i].format(values[i], total) + (i + 1 === values.length ? "\n" : ",");
	process.stdout.write(out);

	const temp = valuesOld;
	valuesOld = values;
	values = temp;
}

// Parse JSON

let mangoAllTagsRaw = undefined;
let mangoAllClientsRaw = undefined;

function mangoParse() {
	if (!mangoAllTagsRaw || !mangoAllClientsRaw)
		return;

	const allTags = JSON.parse(mangoAllTagsRaw).all_tags;
	const allClients = JSON.parse(mangoAllClientsRaw).clients;
	const focusedClient = allClients.find(v => v.is_focused);

	parseInfo({ allClients, allTags, focusedClient });
}

// Debounce mmsg

let mangoParseDebounceTimeout = undefined;
function mangoParseDebounceRun() {
	if (mangoParseDebounceTimeout)
		clearTimeout(mangoParseDebounceTimeout);
	mangoParseDebounceTimeout = setTimeout(mangoParse, DEBOUNCE_MS);
}

runStream("mmsg watch all-tags", line => {
	mangoAllTagsRaw = line;
	mangoParseDebounceRun();
});

runStream("mmsg watch all-clients", line => {
	mangoAllClientsRaw = line;
	mangoParseDebounceRun();
});
