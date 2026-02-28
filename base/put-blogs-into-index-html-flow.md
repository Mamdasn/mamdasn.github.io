# How `put-blogs-into-index-html.sh` connects files

When `base/put-blogs-into-index-html.sh` is executed, the execution flow is shown below.

## 1. Main HTML build

- `base/index-struct.html` is the source template.
- The script copies it to `index.html`.
- The script finds `<!-- [POSTS PLACEHOLDER] -->` inside `index.html`.
- Every file in `posts/` is read, sorted by filename, and inserted into that placeholder area.
- The script then finds `<!-- [POSTSLIST PLACEHOLDER] -->` inside `index.html`.
- The same `posts/*.html` files are parsed again to extract:
  - the post title from `<h2 ... id="post-N">`
  - the post id (`N`) from the same `<h2>`
- From that data, the script writes a table of contents into `index.html` as links like `#post-N`.

## 2. RSS build

- `base/rss-struct.xml` is the RSS template.
- The script copies it to `rss.xml`.
- The script finds `<!-- [FEED PLACEHOLDER] -->` inside `rss.xml`.
- The same `posts/*.html` files are parsed again to extract:
  - title
  - post id
  - first paragraph
  - date from `<div class="time-tag">`
- That data is converted into `<item>` entries and inserted into `rss.xml`.

## 3. Frontend assets used by the generated page

- `index.html` keeps the `<link>` tags that already exist in `base/index-struct.html`.
- Because of that, the generated `index.html` still depends on:
  - `assets/css/index.css`
  - `assets/css/w3.css`
  - `assets/css/montserrat.css`
  - `assets/Icon-Web.ico`
- `assets/css/index.css` styles classes and ids that appear in `base/index-struct.html` and in the inserted `posts/*.html` content, such as `.time-tag`.

## 4. Short dependency map

```text
base/index-struct.html ----copy----> index.html
posts/*.html --------------insert--> index.html (post bodies)
posts/*.html --------------parse---> index.html (table of contents)

base/rss-struct.xml -------copy----> rss.xml
posts/*.html --------------parse---> rss.xml (RSS items)

assets/css/index.css ------used by-> index.html (via link tag from template)
assets/css/w3.css ---------used by-> index.html
assets/css/montserrat.css -used by-> index.html
assets/Icon-Web.ico -------used by-> index.html
```
