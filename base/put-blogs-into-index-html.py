import os
import platform
import sys

slash = '/' if platform.system() == 'Linux' else '\\'
blogs_folder = 'blogs-by-topics'

if os.getcwd().split(slash)[-1] == 'base':
    os.chdir('..')

with open(f'base{slash}index-struct.html', 'r') as f:
    html_base_file = f.read()

blogs = os.listdir(blogs_folder)
sorted(blogs, key= lambda blog: blog.split('.')[0])
blog_txts = ''
for blog in blogs:
    print(blog)
    with open(f"{blogs_folder}{slash}{blog}", 'r') as f:
        blog_txt = f"{f.read()}\n \
                      <br>\n \
                      <div class='horizontalline'></div>"
        blog_txts = f"{blog_txts}\n{blog_txt}"

html_base_file = html_base_file.replace('<!-- [] -->', f"{blog_txts}")
    
instr = input('File index.html is going to be replaced, are you sure?[yN]')
if instr != 'y':
    print('index.html is intact.')
    sys.exit()
else:
    print('Continuing...')
with open('index.html', 'w') as f:
    f.write(html_base_file)
print('Done.')
