#!/bin/bash

prepare_template(){
    cp common/template.html "$1"
}

fill_template_common(){
    shopt -s extglob

    old="head.html"
    new="$(tr '\n' ' ' < common/head.html)"
    
    for common in $(ls common); do
        old="$common"
        new="$(tr '\n' ' ' < common/"$common")"
        rule="""s|$old|$new|"""
        sed -i -r -e "$rule" "$1"
    done
}

fill_template_content(){
    old="SomeContent"
    
    new="$(tr '\n' ' ' < "$2")"
    echo "Content: $1 $2"
    rule="""s|$old|$new|"""
    sed -i -r -e "$rule" "$1"
    sed -i -r -e """s|cssfile|$cssfile|""" "$1"
    sed -i -r -e """s|faviconico|$faviconico|""" "$1"
    sed -i -r -e """s|profilepic|$profilepic|""" "$1"
    sed -i -r -e """s|pagelinks|$pagelinks|""" "$1"
}

hotfix_remove_template_content(){
    #TODO remove hotfix by directly not inserting "SomeContent" into pages. But I dont know yet how that happend.
    sed -i -r -e 's|SomeContent ||g' "$1"
}

set_index(){
    if [[ "$1" == *".html" ]]; then
        (
            cd "$final_dir" || return 1
            rm -f "index.html"
            ln -s "$1" "index.html"
        )
    else
        echo "Argument 1 must be .html file, was $1"
    fi
}

test_site(){
    html_file="$1"

    trim_command="tr -d 'n' | sed 's/ //g'"
    trimmed_content_a=$(cat "$final_dir/$html_file" | $trim_command 2>/dev/null)
    trimmed_content_b=$(cat "pages/$html_file" | $trim_command 2>/dev/null)

    if [[ "$trimmed_content_a" != *"$trimmed_content_b"* ]]; then
        >&2 echo "$1 was not correct build!"
    fi
}

parse_blog_entry_line(){
    if [ "$line_index" -eq 0 ]; then
        parsed_blog_entries=$(cat << EOF
    <h2>$line</h2>
    <div class="articletext">
EOF
        )
    else 
        parsed_blog_entries=$(cat << EOF
    $parsed_blog_entries
    <par>    
    $line   
    </par>  
EOF
        )
    fi   
    line_index=$((line_index+=1))
}

parse_blog_entry(){
    if [[ "$(tail -c 1 "$blog_entry_file")" != "" ]]; then
        echo "File '$blog_entry_file' without empty last line, will append it now"
        echo "" >> "$blog_entry_file"
    fi

    parsed_blog_entries=""
    line_index=0
    while IFS= read -r line; do
        parse_blog_entry_line
    done < "$blog_entry_file"
        
    parsed_blog_entries=$(cat << EOF
    $parsed_blog_entries
    </div>
EOF
    )
    echo "$parsed_blog_entries"
}

create_blog_content(){
    # Build pages/blog.html
    echo > pages/blog.html
    blog_entry_dir=pages/blog_entries

    for blog_entry_file in "$blog_entry_dir"/*; do
        echo "$blog_entry_file"

        parsed_blog_entries=$(parse_blog_entry)
        
        echo "<article>
$parsed_blog_entries
</article>" >> pages/blog.html
    done

    sed '/pleaseinsertcontenthere/{
            s/pleaseinsertcontenthere//g
            r pages/blog.html
        }' pages/blogv2raw.html > pages/blogv2.html
}

(
    cd pieces || exit 1

    final_dir=".." 
    testing_final_dir="$final_dir/testdir"
    index_site="publications.html"
    all_sites=("404" "impressum" "publications" "skills" "blogv2") #Intentionally missing: "blog"
    cssfile="resources/style.css"
    faviconico="resources/favicon.ico"
    profilepic="resources/profile.png"

    bloglink="<a href=blogv2.html>Blog</a>"
    publicationlink="<a href=publications.html>Publications</a>"
    skilllink="<a href=skills.html>Skills</a>"
    pagelinks="$bloglink, $publicationlink, $skilllink" #Intentionally missing: "$bloglink, "

    if [ "$1" = "-t" ]; then
        mkdir -p "$testing_final_dir"
        final_dir="$testing_final_dir"
    else
        cssfile="pieces/$cssfile"
        faviconico="pieces/$faviconico"
        profilepic="pieces/$profilepic"
    fi

    create_blog_content

    for page in "${all_sites[@]}"; do
        final_page="$final_dir/$page.html"

        prepare_template "$final_page"
        fill_template_common "$final_page"
        fill_template_content "$final_page" "pages/$page.html"
        hotfix_remove_template_content "$final_page"

        test_site "$page.html"
    done

    set_index $index_site
)

# TODO for some reason BSD sed (MacOS) creates "${page}.html-r" files. Think some arguments are differently used from Linux / BSD
rm -f ./*.html-r
