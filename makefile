FORCE:

tests:
	cd better_cryptography && dart test --platform=vm
	cd better_jwk && dart test --platform=vm

flutter_integration_tests:
	cd better_cryptography_flutter/example && flutter clean && flutter test integration_test

prod: github

commit: FORCE tests
	git add .
	git commit -a

github: FORCE tests
	git add .
	git commit -a
	git push

publish_all: FORCE tests
	cd better_cryptography && dart pub publish
	cd better_cryptography_flutter && dart pub publish
	cd better_jwk && dart pub publish

pub_get: FORCE
	cd better_cryptography && dart pub get
	cd better_cryptography_flutter && flutter pub get
	cd better_jwk && dart pub get
