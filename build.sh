#!/bin/bash

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
        sed -i -r -e "$rule" "$1"
    done
}

fill_template_content(){
    old="SomeContent"
    
    new="$(cat $2 | tr '\n' ' ')"
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
            cd "$final_dir"
            rm -f "index.html"
            ln -s "$1" "index.html"
        )
    else 
        echo "Argument 1 must be .html file, was $1"
    fi
}

test_site(){
    trim_command="tr -d 'n' | sed 's/ //g'"
    if [[ "$(cat $final_dir/$1 | $trim_command 2>/dev/null)" != *"$(cat pages/$1 | $trim_command 2>/dev/null)"* ]]; then
        >&2 echo "$1 was not correct build!"
    fi
}

create_blog_content(){
    # Build pages/blog.html
    echo > pages/blog.html
    blog_entry_dir=pages/blog_entries
    for blog_entry in $(ls $blog_entry_dir); do
        blog_entry_file="$blog_entry_dir/$blog_entry"
        echo "$blog_entry_file"

        if [[ "$(tail -c 1 "$blog_entry_file")" != "" ]]; then
            echo "File '$blog_entry_file' without empty last line, will append it now"
            echo "" >> "$blog_entry_file"
        fi

        blog_entry_parsed=""
        line_index=0
        while IFS= read -r line; do

            if [ $line_index -eq 0 ]; then
                blog_entry_parsed=$(cat << EOF
    <h3 class="articlehead">$line</h3>
    <div class="articletext">
EOF
    )
            else 
                blog_entry_parsed=$(cat << EOF
    $blog_entry_parsed
    <par>    
    $line   
    </par>  
EOF
    )
            fi
            
            line_index=$((line_index+=1))
        done < "$blog_entry_file"
                blog_entry_parsed=$(cat << EOF
    $blog_entry_parsed
    </div>
EOF
    )
        echo "<article>
    $blog_entry_parsed
    </article>" >> pages/blog.html
        echo $line_index
    done
}

(
    cd pieces || exit 1

    final_dir=".." 
    testing_final_dir="$final_dir/testdir"
    index_site="publications.html"
    all_sites=("404" "blog" "impressum" "publications" "skills")
    cssfile="resources/style.css"
    faviconico="resources/favicon.ico"
    profilepic="resources/profile.png"

    bloglink="<a href=blog.html>Blog</a>"
    publicationlink="<a href=publications.html>Publications</a>"
    skilllink="<a href=skills.html>Skills</a>"
    pagelinks="$bloglink, $publicationlink, $skilllink"

    if [ "$1" = "-t" ]; then
        mkdir -p "$testing_final_dir"
        final_dir="$testing_final_dir"
    else
        cssfile="pieces/$cssfile"
        faviconico="pieces/$faviconico"
        profilepic="pieces/$profilepic"
    fi

    create_blog_content

    for page in ${all_sites[@]}; do
        final_page="$final_dir/$page.html"

        prepare_template "$final_page"
        fill_template_common "$final_page"
        fill_template_content "$final_page" "pages/$page.html"
        hotfix_remove_template_content "$final_page"

        test_site "$page.html"
    done

    set_index $index_site
)