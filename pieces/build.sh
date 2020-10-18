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
    # TODO, this creates problems with "skills.html" format
    new="$(cat $2 | tr '\n' ' ')"
    echo "Content: $1 $2"
    rule="""s|$old|$new|"""
    sed -i -r -e "$rule" $1
}

hotfix_remove_template_content(){
    #TODO remove hotfix by directly not inserting "SomeContent" into pages. But I dont know yet how that happend.
    sed -i -r -e 's|SomeContent ||g' $1
}

for page in $(ls pages); do
    # TODO dynamically set index.html
    # TODO dynamically set links to other pages
    # TODO end testing and save files to repo root.

    final_page="$final_dir/$page"

    prepare_template "$final_page"
    fill_template_common "$final_page"
    fill_template_content "$final_page" "pages/$page"
    hotfix_remove_template_content "$final_page"
done

