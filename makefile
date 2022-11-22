FORCE:

tests:
	cd better_cryptography && dart test --platform=vm
	cd better_jwk && dart test --platform=vm

flutter_integration_tests:
	cd better_cryptography_flutter/example && flutter clean && flutter test integration_test

prod: FORCE github

commit: FORCE tests 
	git add .
	git commit -a

github: FORCE remove_junk_files tests
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

remove_icloud_files: FORCE
	find . -name "*.icloud" -type f -delete

remove_duplicate_files: FORCE
	find . -name "*.mocks *" -type f -delete
	find . -name "*.freezed *" -type f -delete
	find . -name "*.config *" -type f -delete
	find . -name "* *. *" -type f -delete
	find . -name "* *" -type f -delete

remove_junk_files: remove_duplicate_files remove_icloud_files