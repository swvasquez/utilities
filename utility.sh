#!/bin/bash

# This script creates an empty utility script, makes it executable, and
# adds a corresponding symlink to a $PATH-linked directory. Scripts
# are grouped together under specified categories, which must be provided by 
# the user.

get_category () {
    read -p "Script category: " category
    echo $category
}

get_utility () {
    read -p "Script name: " script
    echo $script
}

make_executable (){
    chmod +x $1
}

create_symlink (){
    ln -s "${2}/${1}.sh" "${3}/${1}"
}

create_script(){
    file_path="${2}/${1}.sh"
    touch $file_path
    echo "#!/bin/bash" >> $file_path
    make_executable $file_path
    create_symlink ${1} ${2} ${3}
}

create_readme () {
    file_path="${1}/${2}/README.md"
    touch $file_path
}

get_info () {
    if [[ $# == 0 ]]; then
        category=$(get_category)
        utility=$(get_utility)
    elif [[ $# == 1 ]]; then
        category=$(get_category)
        utility=$1
    else
        category=$1
        utility=$2
    fi

    # In case of name collision, the user can choose what to do next.
    if [[ -e "${bin_dir}/${utility}" ]];then
        echo "A script named ${utility} already exists."
        PS3="Do you want to open it? "
        select yn in "yes" "no" "quit"; do
            case $yn in
                yes) code $(readlink -f "${bin_dir}/${utility}"); exit;;
                no) utility=$(get_utility); get_info $category $utility; break;;
                quit) exit;;
            esac
        done
    fi
}

# Program starts here. 
utilities_dir=$(dirname $(readlink -f $0))
bin_dir="${utilities_dir}/bin"

get_info $1 $2
utility_dir="${utilities_dir}/${category}/${utility}"

mkdir -p $utility_dir
create_script $utility $utility_dir $bin_dir
create_readme $utility_dir 





