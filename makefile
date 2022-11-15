FORCE:

tests:
	cd better_cryptography && dart test --platform=vm
	cd better_jwk && dart test --platform=vm

prod: github

commit: FORCE tests
	git add .
	git commit -a
 
github: FORCE tests
	git add .
	git commit -a
	git push