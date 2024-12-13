#!/bin/bash

function get_topic {
    BLOGPATH="$1"
    [ -z "$BLOGPATH" ] && echo Please provide a path to the file && exit 1
    TOPIC=$(sed -n 's|<h2 class="[^"]*" id="post-[0-9]*".*>\(.*\)</h2>|\1|p' "$BLOGPATH")
    echo "$TOPIC" | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g;'
}

function get_date {
    BLOGPATH="$1"
    [ -z "$BLOGPATH" ] && echo Please provide a path to the file && exit 1
    DATE=$(sed -n 's|<div class="time-tag">\([^<]*\)</div>|\1|p' "$BLOGPATH")
    echo $DATE | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g'
}

function get_first_paragraph {
    BLOGPATH="$1"
    [ -z "$BLOGPATH" ] && echo Please provide a path to the file && exit 1
    CURSOR="$(grep -n '<p>'  $BLOGPATH | cut -d ':' -f1)"
    echo "$CURSOR" | while read LINE_NUM; 
    do
        FIRST_PARAGRAPH=$(sed -n "s/^[[:space:]]*//g;s/[[:space:]]*$//g;${LINE_NUM}p" "$BLOGPATH")
        while [ ${#FIRST_PARAGRAPH} -le 3 ]; 
        do
            LINE_NUM=$((LINE_NUM+1))
            FIRST_PARAGRAPH=$FIRST_PARAGRAPH$(sed -n "s/^[[:space:]]*//g;s/[[:space:]]*$//g;${LINE_NUM}p" "$BLOGPATH")
        done
        FIRST_PARAGRAPH=$(echo "$FIRST_PARAGRAPH" | sed "s/^<p>//g" | cut -c 1-70 | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g')
        echo "$FIRST_PARAGRAPH..."
        [ ${#FIRST_PARAGRAPH} -gt 3 ] && break
    done
}

function get_topic_id {
    BLOGPATH="$1"
    [ -z "$BLOGPATH" ] && echo Please provide a path to the file && exit 1
    TOPIC_ID=$(sed -n 's|<h2 class="[^"]*" id="post-\([0-9]*\)".*>.*</h2>|\1|p' "$BLOGPATH")
    echo "$TOPIC_ID" | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g;'
}


# DEFINE GLOBAL VARS
BASEINDEX='base/index-struct.html'
INDEX='index.html'

BLOGSDIR='posts'
BLOGNAMES=$(ls $BLOGSDIR | sort -k1.1,1.2n)

BASERSS='base/rss-struct.xml'
RSS='rss.xml'


# INITIALIZE A FRESH index.html
cp $BASEINDEX $INDEX


# SETUP POSTS IN index.html
CURSOR=$(grep -n '<!-- \[POSTS PLACEHOLDER\] -->'  $INDEX | cut -d ':' -f1)

echo "$BLOGNAMES" | while read BLOGNAME; 
do 
    BLOGPATH="$BLOGSDIR/$BLOGNAME"
    [ "$(echo "$BLOGNAMES" | head -1)" != "$BLOGNAME" ] &&  
        SPACER='<div style="height: 50px;"></div>' &&
            sed -i "${CURSOR}a\\$SPACER" $INDEX
    sed -i "${CURSOR}r $BLOGPATH" $INDEX
done


# SETUP TABLE OF CONTENTS IN index.html
CURSOR=$(grep -n '<!-- \[POSTSLIST PLACEHOLDER\] -->'  $INDEX | cut -d ':' -f1)

TOPIC_LINES="$(grep '<h2 class="\S*" id="post-[0-9]*".*>.*</h2>' $INDEX)"

echo "$BLOGNAMES" | while read BLOGNAME; 
do 
    BLOGPATH="$BLOGSDIR/$BLOGNAME"
    TOPIC=$(get_topic "$BLOGPATH")
    TOPIC_ID=$(get_topic_id "$BLOGPATH")
    HYPERLINK="<a href='#post-$TOPIC_ID'>$TOPIC_ID. $TOPIC</a>"
    printf '%s\n' "$HYPERLINK" | sed -i "${CURSOR}r /dev/stdin" "$INDEX"
done


# INITIALIZE A FRESH rss.xml
cp $BASERSS $RSS


# SETUP RSS FEED IN rss.xml
CURSOR=$(grep -n '<!-- \[FEED PLACEHOLDER\] -->'  $RSS | cut -d ':' -f1)

echo "$BLOGNAMES" | while read BLOGNAME; 
do 
    BLOGPATH="$BLOGSDIR/$BLOGNAME"
    echo $BLOGPATH
    TITLE="<title>"$(get_topic "$BLOGPATH")"</title>"
    LINK="<link>https://farhadsplatz.de/#post-"$(get_topic_id "$BLOGPATH")"</link>"
    DESCRIPTION="<description>"$(get_first_paragraph "$BLOGPATH")"</description>"
    PUBDATE="<pubDate>"$(get_date "$BLOGPATH")"</pubDate>"
    GUID="<guid>https://farhadsplatz.de/#post-"$(get_topic_id "$BLOGPATH")"</guid>"

    FEED=$(printf '\t<item>\n\t\t%s\n\t\t%s\n\t\t%s\n\t\t%s\n\t\t%s\n\t</item>' "$TITLE" "$LINK" "$DESCRIPTION" "$PUBDATE" "$GUID")
    printf '%s\n\n' "$FEED" | sed -i "${CURSOR}r /dev/stdin" "$RSS"
done
