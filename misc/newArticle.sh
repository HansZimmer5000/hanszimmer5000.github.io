#!/bin/sh

print_help() {
	echo "This function creates an html article with title (h3) and text."
	echo 
	echo "Arguments:"
	echo "1: Article title"
	echo "2: Article text"
}

create_article() {
	newArticle="<article><h3 class="articlehead">$1<\/h3><div class="articletext">$2<\/div><\/article>"
	echo $newArticle
}

insert_article() {
	# Replace first <article> with this all (and add aditional <article> in the end)
	subString="<article>"
	replaceString="$2<article>"

	newHTML=$(echo "$1" | sed -e "s/$subString/$replaceString/")
	echo $newHTML
}

delete_article() {
	#https://stackoverflow.com/questions/10613643/replace-a-unknown-string-between-two-known-strings-with-sed#10613688
	subString="<article>[.\?]<\/article"
	replaceString=""
	#sed -i 's/(WORD1).*(WORD3)/\1 foo \2/g'
	subString="<article>.*<\/article>"
	newHTML=$(echo "$1" | sed -e "s/<article>.*<\/article>/$replaceString/")
	echo $newHTML
}

if [ $# -eq 2 ]; then
	newArticle=$(create_article "$1" "$2")
	oldHtml=$(cat index.html)
	newHTML=$(insert_article "$oldHtml" "$newArticle")
	newHTML=$(delete_article "$oldHtml")

	# Newlines are not ignorred!
	subString=""
	replaceString=""

	newHTML=$(echo "$oldHtml" | sed "s/.*/TESTINPUT/g")
	echo $newHTML > d.html
else
	print_help
fi
