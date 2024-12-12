#!/bin/bash

BASEINDEX='base/index-struct.html'
INDEX='index.html'

cp $BASEINDEX $INDEX

CURSOR=$(grep -n '<!-- \[POSTS PLACEHOLDER\] -->'  $INDEX | cut -d ':' -f1)

SPACER='<div style="height: 50px;"></div>'

BLOGSDIR='blogs-by-topics'
BLOGNAMES=$(ls $BLOGSDIR | sort -k1.1,1.2n)

echo "$BLOGNAMES" | while read BLOGNAME; 
do 
    BLOGPATH="$BLOGSDIR/$BLOGNAME"
    [ "$(echo "$BLOGNAMES" | head -1)" != "$BLOGNAME" ] &&  
        sed -i "${CURSOR}a\\$SPACER" $INDEX
    sed -i "${CURSOR}r $BLOGPATH" $INDEX
done

CURSOR=$(grep -n '<!-- \[POSTSLIST PLACEHOLDER\] -->'  $INDEX | cut -d ':' -f1)

TOPIC_LINES="$(grep '<h2 class="\S*" id="post-[0-9]*".*>.*</h2>' $INDEX)"

echo "$TOPIC_LINES" | tac | while read TOPIC_LINE; 
do 
    TOPIC="$(echo "$TOPIC_LINE" | sed 's/<[^>]*>//g;s/^[[:space:]]*//g;s/[[:space:]]*$//g')"
    TOPIC_NUMBER="$(echo "$TOPIC_LINE" | sed 's/.*id="post-\([0-9]*\)".*/\1/g')"
    HYPERLINK="<a href='#post-$TOPIC_NUMBER'>$TOPIC_NUMBER. $TOPIC</a>"
    [ "$(echo "$TOPIC_LINES" | head -1)" != "$TOPIC_LINE" ] &&  
        sed -i "${CURSOR}a\\\n" $INDEX
    sed -i "${CURSOR}a\\$HYPERLINK" $INDEX
done

