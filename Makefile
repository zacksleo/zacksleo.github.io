pull:
	git pull origin docs
deploy:
	git add . && git commit -m 'update docs' && git push origin docs