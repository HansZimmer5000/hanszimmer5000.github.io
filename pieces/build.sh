#!/bin/bash

testing=true
final_dir=".." 
testing_final_dir="."
index_site="publications.html"
sites_to_link=("blog" "publications" "skills")

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
    # TODO with "tr" this works, problem will be when we fill the content that has multi lines.
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
    new="$(cat $2)"
    filled_page=$(echo "$1" | sed -e "s/$old/$new/")
    echo "$filled_page" > "$1" 
}

for page in $(ls pages); do
    final_page="$final_dir/$page"

    prepare_template "$final_page"
    fill_template_common "$final_page"
    #fill_template_content "$final_page" "$page"
done

