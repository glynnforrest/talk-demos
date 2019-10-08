.PHONY: setup install clean

setup: install clean

install:
	composer install
	(cd 1-twig-extension; composer install)
	(cd 3-old-code; composer dump-autoload)
	(cd 4-custom-rector; composer dump-autoload)

clean:
	git checkout 1-twig-extension
	git checkout 2-messy-code
	git checkout 3-old-code
	git checkout 4-custom-rector

fullclean: clean
	rm -rf 1-twig-extension/vendor
	rm -rf 3-old-code/vendor
	rm -rf 4-custom-rector/vendor
