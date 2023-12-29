import os
import sys
from bs4 import BeautifulSoup

blogs_folder = 'blogs-by-topics'

# Check if the current directory is 'base' and if so, change to the parent directory
if os.path.basename(os.getcwd()) == 'base':
    os.chdir('..')

# Read the base structure of the HTML file
with open(os.path.join('base', 'index-struct.html'), 'r') as f:
    html_base_file = f.read()

blogs = os.listdir(blogs_folder)

# List the blogs and sort them
blogs = sorted(os.listdir(blogs_folder), key=lambda blog: blog.split('.')[0], reverse=True)

print("Blogs:")
for blog in blogs:
    print(blog)

# Read all blog contents into a list using a list comprehension
blog_txt_list = [open(os.path.join(blogs_folder, blog), 'r').read() for blog in blogs]

# Read all blog topics and links into a list using a list comprehension
posts_topics = [BeautifulSoup(blog, "html.parser").find('h2', {'id': True, 'class': 'w3-text-light-grey'}).get_text(strip=True) for blog in blog_txt_list]
posts_links   = [BeautifulSoup(blog, "html.parser").find('h2', {'id': True, 'class': 'w3-text-light-grey'})['id'] for blog in blog_txt_list]
posts_topics.reverse()
posts_links.reverse()
posts_topics_links_list = []
for index, (link, topic) in enumerate(zip(posts_links, posts_topics)):
    posts_topics_links_list.append(f"<a href='#{link}'>{index+1}. {topic}</a>")
posts_topics_links_list.reverse()
posts_topics_links = " || \n    ".join(posts_topics_links_list)

# Replace the postslist placeholder with the blog topics/links
html_base_file = html_base_file.replace('<!-- [POSTSLIST PLACEHOLDER] -->', f"{posts_topics_links}")

# Construct the full blog content with spacers
spacer = '<div style="height: 50px;"></div>'
blog_txts = f"\n{spacer}\n".join(blog_txt_list)

# Replace the posts placeholder with the blog contents
html_base_file = html_base_file.replace('<!-- [POSTS PLACEHOLDER] -->', f"{blog_txts}")

# Prompt user for confirmation to replace the index.html file
instr = input('File index.html is going to be replaced, are you sure?[yN] ')
if instr != 'y':
    print('index.html is kept intact.')
    sys.exit()
else:
    print('Continuing...')

# Write the combined content to index.html
with open('index.html', 'w') as f:
    f.write(html_base_file)

print('Done.')
