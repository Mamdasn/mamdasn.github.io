import os
import sys

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

# Construct the full blog content with spacers
spacer = '<div style="height: 50px;"></div>'
blog_txts = f"\n{spacer}\n".join(blog_txt_list)

# Replace the post placeholder with the blog contents
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
