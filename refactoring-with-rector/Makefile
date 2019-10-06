.PHONY: setup install clean

setup: install clean

install:
	composer install
	(cd 1-twig-extension; composer install)

clean:
	git checkout 1-twig-extension
