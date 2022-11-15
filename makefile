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

publish: FORCE tests
	cd better_cryptography && dart pub publish
	cd better_cryptography_flutter && dart pub publish
	cd better_jwk && dart pub publish