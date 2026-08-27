# Bash Launcher

Run bash commands from the launcher. Supports bash completion.

## Plugin

| Field | Value |
| --- | --- |
| ID | `aurelia/bash_launcher` |
| Entries | Launcher Provider: `bash_launcher` |
| Launcher Prefix | `/$` |

## Usage

Has no non visual behaviour

## Settings

| setting | type | default | description |
| --- | --- | --- | --- |
| `terminal_command` | `string` | `"setsid kitty --hold -- bash \"$SCRIPT\"` | Command to run when opening terminal with bash launcher. $SCRIPT is replaced. |
