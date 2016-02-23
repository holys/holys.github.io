# 折中做法： mweb 编辑器的图片支持与 hexo 的 images 目录不兼容，
#只能在部署的时候多拷贝一份到 hexo 的 image 目录
for file in ./source/_posts/images/*
do
   if test -f $file
   then
       cp -f $file ./source/images/
   fi
done
