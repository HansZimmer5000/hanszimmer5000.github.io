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
    touch "$1"
    echo "
<!doctype html>
<html lang='en' class='no-js'>
" > "$final_page"
}

fill_upper(){

}

fill_content(){

}

fill_lower(){

}

for page in $(ls pages); do
    final_page="$final_dir/$page"

    prepare_template "$final_page"
    fill_upper "$final_page"
    fill_content "$final_page" "pages/$page"
    fill_lower "$final_page"
    echo "</html>" > "$final_page"
done

