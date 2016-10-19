.PHONY: deploy preview

preview:
	hexo clean
	@sh copy.sh
	hexo g
	hexo serve --watch
	
deploy:
	hexo clean
	@sh copy.sh
	hexo g -d
	 
