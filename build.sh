#!/bin/bash

log(){
    echo "$*"
}

log_err(){
    log "$*" 1>&2
}

prepare_template(){
    cp common/template.html "$1"
}

fill_template_common(){
    shopt -s extglob

    old="head.html"
    new="$(tr '\n' ' ' < common/head.html)"
    common_files="$(ls common)"
    
    for common in $common_files; do
        old="$common"
        new="$(tr '\n' ' ' < common/"$common")"
        rule="""s|$old|$new|"""
        sed -i -r -e "$rule" "$1"
    done
}

fill_template_content(){
    old="SomeContent"
    new="$(tr '\n' ' ' < "$2")"
    new="${new//&/\&}"

    echo "Content: $1 $2"
    rule="""s#$old#$new#"""
    sed -i -r -e "$rule" "$1"
    sed -i -r -e """s|cssfile|$cssfile|""" "$1"
    sed -i -r -e """s|faviconico|$faviconico|""" "$1"
    sed -i -r -e """s|profilepic|$profilepic|""" "$1"
    sed -i -r -e """s|pagelinks|$pagelinks|""" "$1"
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

siteb_is_in_sitea(){
    if ! test -f "$1"; then
        log_err "siteb_is_in_sitea: could not find $1"
        return 1
    fi
    if ! test -f "$2"; then
        log_err "siteb_is_in_sitea: could not find $2"
        return 1
    fi

    trimmed_content_a=$(tr -d '\n' < "$1" | sed 's/ //g')
    trimmed_content_b=$(tr -d '\n' < "$2" | sed 's/ //g')

    if [[ "$trimmed_content_a" != *"$trimmed_content_b"* ]]; then
        log_err "siteb_is_in_sitea: $2 was not $1"
        return 1
    fi

    return 0
}

test_site(){
    html_file="$1"

    siteb_is_in_sitea "$final_dir/$html_file" "pages/$html_file" || echo "TODO fix siteb_is_in_sitea"
    siteb_is_in_sitea "$final_dir/$html_file" "common/footer.html" || echo "TODO fix siteb_is_in_sitea"
}

parse_blog_entry(){
    if [[ "$(tail -c 1 "$blog_entry_file")" != "" ]]; then
        echo "File '$blog_entry_file' without empty last line, will append it now"
        echo "" >> "$blog_entry_file"
    fi

    parsed_blog_entry=""
    line_index=0
    while IFS= read -r line; do
        parse_blog_entry_line
    done < "$blog_entry_file"
        
    parsed_blog_entry=$(cat << EOF
    $parsed_blog_entry
    </div>
EOF
    )
    echo "$parsed_blog_entry"
}

parse_blog_entry_line(){
    if [ "$line_index" -eq 0 ]; then
        : # Ignore first html comment 
    elif [ "$line_index" -eq 1 ]; then
        parsed_blog_entry=$(cat << EOF
    <h2><a href="$single_blog_entry_file">$line</a></h2>
    <div class="articletext">
EOF
        )
    elif [ "$line_index" -eq "$last_line_index" ]; then
        parsed_blog_entry=$(cat << EOF
$parsed_blog_entry
</div>
EOF
        )
    else 
        parsed_blog_entry=$(cat << EOF
    $parsed_blog_entry
    <par>
    $line
    </par>
EOF
        )
    fi   
}

parse_blog_entry(){
    if [[ "$(tail -c 1 "$blog_entry_file")" != "" ]]; then
        echo "File '$blog_entry_file' without empty last line, will append it now"
        echo "" >> "$blog_entry_file"
    fi

    parsed_blog_entry=""
    line_index=0
    line_count="$(wc -l < "$blog_entry_file" | sed 's| ||g')"
    last_line_index="$(($line_count-1))"

    html_comment=$(head -n 1 "$blog_entry_file")
    case "$html_comment" in 
        "<!--raw-->")
            line="$(head -n 2 "$blog_entry_file" | tail -n 1)" line_index=1 parse_blog_entry_line
            line="$(tail -n+2 "$blog_entry_file")" line_index=2 parse_blog_entry_line
            ;;
        "<!--article-->")
            while IFS= read -r line; do
                parse_blog_entry_line
                line_index=$((line_index+=1))
            done < "$blog_entry_file"
            ;;
        *)
            echo "No HTML comment as first line of blog entry: $blog_entry_file. Exiting" 1>&2
            exit 1
            ;;
    esac

    echo "$parsed_blog_entry"
}

create_single_blog_entry_page(){
    local final_page="$1"
    local blog_entry="$2"

    echo "$blog_entry" > tmpfile
    prepare_template "$final_page"
    fill_template_common "$final_page"
    fill_template_content "$final_page" tmpfile
    rm tmpfile
    mv blog-*.html* ..  1>&2
}

create_blog_content(){
    # Build pages/blog.html
    echo > pages/blog_entries.html
    blog_entry_dir=pages/blog_entries
    blog_entry_files="$(ls $blog_entry_dir)"
    blog_entry_file_sorted_most_current_first="$(echo "$blog_entry_files" | sort -r)"

    for blog_entry_file_without_dir in $blog_entry_file_sorted_most_current_first; do
        blog_entry_file="$blog_entry_dir/$blog_entry_file_without_dir"
        single_blog_entry_file="blog-$blog_entry_file_without_dir"

        parsed_blog_entry=$(parse_blog_entry)
        create_single_blog_entry_page "$single_blog_entry_file" "$parsed_blog_entry"

        echo "<article>
$parsed_blog_entry
</article>" >> pages/blog_entries.html
    done
    sed '/pleaseinsertcontenthere/{
            s/pleaseinsertcontenthere//g
            r pages/blog_entries.html
        }' pages/blograw.html > pages/blog.html
}

create_final_page(){
    final_page="$final_dir/$page.html"

    prepare_template "$final_page"
    fill_template_common "$final_page"
    fill_template_content "$final_page" "pages/$page.html"

    test_site "$page.html"
}

final_dir=".." 
testing_final_dir="$final_dir/testdir"
index_site="publications.html"
all_sites=("404" "impressum" "publications" "skills" "blog") #Intentionally missing: "blog"
cssfile="resources/style.css"
faviconico="resources/favicon.ico"
profilepic="resources/profile.png"

bloglink="<a href=blog.html>Blog</a>"
publicationlink="<a href=publications.html>Publications</a>"
skilllink="<a href=skills.html>Skills</a>"
pagelinks="$bloglink, $publicationlink, $skilllink" #Intentionally missing: "$bloglink, "

set -e

(
    cd pieces || exit 1

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
        create_final_page
    done

    set_index $index_site
)

# TODO for some reason BSD 'sed' (MacOS) creates "${page}.html-r" files. Think some arguments are differently used from Linux to BSD
rm -f ./*.html-r ./testdir/*.html-r
