.PHONY: deploy preview


preview:
	@sh copy.sh
	hexo serve --watch
	
deploy:
	@sh copy.sh
	hexo g -d
	 
