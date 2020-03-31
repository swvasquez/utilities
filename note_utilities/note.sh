#!/bin/bash

# Use to create a Markdown file for note taking. Notes
# are stored in the notes_dir directory.

notes_dir="${HOME}/Documents/notes"

open_note() {
    file_path="${notes_dir}/${1}.md"

    # If note does file doesn't exist, create 
    # a markdown file and open it in VSCode.
    if [[ ! -f $file_path ]]; then
        touch $file_path
        code -n $file_path
    # If a file with the given name exists,
    # either open it or choose a new name.
    else
        echo "${1}.md already exists"
        while true; do
            read -p "Do you want to open this file? " yn
            case $yn in
                [Yy]* ) code -n $file_path; break;;
                [Nn]* ) read -p "Alternative name? " name; 
                        open_note $name; break;;
                * ) exit;;
            esac
        done
    fi
}

# Check for argument and call open_note.
name=$1
if [[ -z $name ]]; then
    read -p "Note name: " name
fi
open_note $name


