#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

cleanup() {
	echo "Cleaning up"
	rm -rf /tmp/official-plugins
}
trap cleanup EXIT

echo "Cloning repo"
git clone --depth 1 https://github.com/noctalia-dev/official-plugins/ /tmp/official-plugins

echo "Copying .gitignore"
cp /tmp/official-plugins/.gitignore .gitignore

echo "Copying .luarc"
cp /tmp/official-plugins/.luaurc .luaurc

echo "Copying noctalia.d.luau"
cp /tmp/official-plugins/noctalia.d.luau noctalia.d.luau

echo "Copying .vscode"
rm -rf .vscode
cp -r /tmp/official-plugins/.vscode .vscode

echo "Copying .github"
rm -rf .github
cp -r /tmp/official-plugins/.github .github
