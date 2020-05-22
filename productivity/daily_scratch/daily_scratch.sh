#!/bin/bash

# Simple script to create daily todo and notes scratch 
# files to jot down whatever come to mind.

scratch_dir="${HOME}/Documents/scratch"
today=$(date +'%m_%d_%Y')
todo="${scratch_dir}/${today}_scratch.md"
notes="${scratch_dir}/${today}_notes.md"


mkdir -p $scratch_dir

dash="--------------------"

test -f $todo || printf '%s\n%s\n%s' $dash "TO DO ${today}" $dash > $todo
test -f $notes|| printf '%s\n%s\n%s' $dash "NOTES ${today}" $dash > $notes

emacs $notes $todo &