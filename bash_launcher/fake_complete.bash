#!/bin/bash

# Written by Hy3
#
# Generalized: complete an arbitrary command line passed as arguments or stdin.
#   ./fake_complete.bash "sudo rm -"
#   echo "make x" | ./fake_complete.bash

source /usr/share/bash-completion/bash_completion

# --- Gather the input line -------------------------------------------------
if [[ $# -gt 0 ]]; then
    line="$*"
else
    line="$(cat)"
fi

# Trailing whitespace means we are starting a brand new (empty) word.
if [[ "$line" =~ [[:space:]]$ ]]; then
    has_trailing=1
else
    has_trailing=0
fi

# Split into words the same way the shell would (respecting quotes).
read -ra words <<< "$line"

# An entirely empty input yields no words; treat it as a single empty word
# so command-name completion (an empty prefix) runs instead of indexing a
# non-existent array element.
if [[ ${#words[@]} -eq 0 ]]; then
    words=("")
fi

# Build the COMP_WORDS array bash completion expects.
COMP_WORDS=("${words[@]}")
if [[ $has_trailing -eq 1 ]]; then
    COMP_WORDS+=("")
fi
COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

COMP_LINE="$line"
COMP_POINT=${#COMP_LINE}
COMP_TYPE=9
COMP_KEY=$'\t'
COMPREPLY=()

# --- Load and run the right completion function ----------------------------
cmd="${COMP_WORDS[0]}"

# completion functions may call compopt, which is invalid outside a real
# completion; shadow it so those functions still populate COMPREPLY.
compopt() { return 0; }

if [[ $COMP_CWORD -eq 0 ]]; then
    # Completing the command name itself: use command-name completion.
    # (No per-command compspec can apply before the command is typed.)
    COMPREPLY=($(compgen -c -- "${COMP_WORDS[COMP_CWORD]}"))
else
    # Make sure a completion definition exists for the command.
    _completion_loader "$cmd" 2>/dev/null

    spec="$(complete -p "$cmd" 2>/dev/null)"
    comp_func=""
    # Ignore the catch-all default/empty-line completions (-D / -E); they only
    # work inside a real completion context and would hide filename fallback.
    if [[ ! "$spec" =~ -D|-E ]] && [[ "$spec" =~ -F\ ([^ ]+) ]]; then
        comp_func="${BASH_REMATCH[1]}"
    fi

    if [[ -n "$comp_func" ]]; then
        "$comp_func"
        # A completer returning nothing lets bash fall back to filenames;
        # mirror that (e.g. the loader's generic minimal completer fails
        # outside a real completion context).
        if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
            COMPREPLY=($(compgen -f -- "${COMP_WORDS[COMP_CWORD]}"))
        fi
    else
        # No programmatic completion: fall back to filename completion.
        COMPREPLY=($(compgen -f -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
fi

for comp in "${COMPREPLY[@]}" ; do
    printf "%s\n" "$comp"
done
