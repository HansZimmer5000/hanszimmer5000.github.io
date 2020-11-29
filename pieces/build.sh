#!/bin/bash

testing=true
final_dir="$PWD/.." 
testing_final_dir="$PWD"
index_site="publications.html"
all_sites=("404" "blog" "impressum" "publications" "skills")

if $testing; then
    final_dir=$testing_final_dir
fi

# TODO consider all pages 
# TODO input template and rename to respective page
# TODO insert input from commons and the respective page

prepare_template(){
    cp common/template.html "$1"
}

fill_template_common(){
    shopt -s extglob

    old="head.html"
    new="$(cat common/head.html | tr '\n' ' ')"

    for common in $(ls common); do
        old="$common"
        new="$(cat common/$common | tr '\n' ' ')"
        rule="""s|$old|$new|"""
        sed -i -r -e "$rule" $1
    done
}

fill_template_content(){
    old="SomeContent"
    # TODO, this creates problems with "skills.html", missing "&"
    new="$(cat $2 | tr '\n' ' ')"
    echo "Content: $1 $2"
    rule="""s|$old|$new|"""
    sed -i -r -e "$rule" $1
}

hotfix_remove_template_content(){
    #TODO remove hotfix by directly not inserting "SomeContent" into pages. But I dont know yet how that happend.
    sed -i -r -e 's|SomeContent ||g' $1
}

set_index(){
    if [[ "$1" == *".html" ]]; then
        rm $final_dir/index.html
        ln -s $final_dir/$1 $final_dir/index.html
    else 
        echo "Argument 1 must be .html file, was $1"
    fi
}

test_site(){
    trim_command="tr -d 'n' | sed 's/ //g'"
    if [[ "$(cat $1 | $trim_command 2>/dev/null)" != *"$(cat pages/$1 | $trim_command 2>/dev/null)"* ]]; then
        >&2 echo "$1 was not correct build!"
    fi
}

for page in ${all_sites[@]}; do
    # dynamically set links to other pages -> not neccessary since index.html is just a link and other names are not changing.
    # TODO end testing and save files to repo root.

    final_page="$final_dir/$page.html"

    prepare_template "$final_page"
    fill_template_common "$final_page"
    fill_template_content "$final_page" "pages/$page.html"
    hotfix_remove_template_content "$final_page"

    test_site $page.html #2>/dev/null
done

set_index $index_site