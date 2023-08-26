import os
import sys
import time
import platform

slash = '\\' if platform.system() == 'Windows' else '/'
blogs_folder = 'blogs-by-topics'

if os.getcwd().split(slash)[-1] == 'base':
    os.chdir('..')

with open(f'base{slash}index-struct.html', 'r') as f:
    html_base_file = f.read()

blogs = os.listdir(blogs_folder)
blogs = sorted(blogs, key= lambda blog: blog.split('.')[0], reverse= True)
blog_txts = ''
for blog in blogs:
    print(blog)
    with open(f"{blogs_folder}{slash}{blog}", 'r') as f:
        # modified_date=time.strftime('%a %H:%M %B %d, %Y', time.localtime(os.path.getmtime(f"{blogs_folder}{slash}{blog}")))
        blog_txt  = ''.join(f.readlines())
        blog_txts = f"{blog_txts}\n{blog_txt}"

html_base_file = html_base_file.replace('<!-- [POSTS PLACEHOLDER] -->', f"{blog_txts}")

instr = input('File index.html is going to be replaced, are you sure?[yN] ')
if instr != 'y':
    print('index.html is intact.')
    sys.exit()
else:
    print('Continuing...')
with open('index.html', 'w') as f:
    f.write(html_base_file)
print('Done.')

# for blog in blogs:
#     with open(f"{blogs_folder}{slash}{blog}", 'r') as f:
#         lines = f.readlines()
#         blog_txt = ''
#         for line in lines:
#             line = f"<p>{line.strip()}</p>" if line.strip() else '<br>'
#             blog_txt = f"{blog_txt}\n{line}"
#         print(blog_txt)
