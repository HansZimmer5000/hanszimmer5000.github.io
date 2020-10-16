#!/bin/bash

#1 = title
#2 = text
fill_template(){
    sed 's|TITLE|'"$1"'|g' template.html > .tmp
    firstString="$(cat .tmp)"
    echo "${firstString/TEXT/$2}" > post.html 
    #sed 's|TEXT'"$2"'|g' .tmp > post.html
    rm .tmp
}

title="24. Dec 19 - Building this Website"
text="<p>I always wanted to have my own website, for experimenting with this 'Web Dev' stuff and also for presenting myself to the world. The target of this website is to be as simple as possible, among other sources, I was inspired by <a target=\"_blank\"
        rel=\"noopener noreferrer\" href=blog.fefe.de>fefe</a> and his rather simple web blog. I want to go one step further and only use HTML and CSS. This of course limits the visual 'wow'-effect but that's OK.
</p>
<p>After I got my domain, I needed a hoster. First I tried DigitalOcean, they are good and not free. I will keep them in mind for later projects but for my low requirements GitHub Pages, for free, seems good.
    <br> The tutorial is very good, even though there is not much to do in the first place. Only the DNS is problematic as no nameserver IPs are listed, weird. My registrar had a <a target=\"_blank\" rel=\"noopener noreferrer\" href=\"https://www.namecheap.com/support/knowledgebase/article.aspx/9645/2208/how-do-i-link-my-domain-to-github-pages\">support
        site</a> specifically for GitHub where I could find these IPs.
</p>
Right now it seems working smooth. Let's see how this turns out in the future."

fill_template "$title" "$text"