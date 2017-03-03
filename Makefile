#
#
#

all: clean install build

build: ;@echo "-- Buidling project"
# elm-make src/App.elm --output=./dist/app.js
	npm run build

dev: ;@echo "-- Staring dev server"
# elm reactor ./src
	npm run dev

clean: ;@echo "-- Cleaning up dist files"
	rm -rf dist/
	rm -rf 1171*

install: ;@echo "-- Installing dependencies"
	elm package install -y
	npm i --silent
	git submodule init
	git submodule update

fix_module_canvas:
	perl -pi -E 's/elm\_community\$canvas/kradalby\$elm\_enigma/g' canvas/src/Native/Canvas.js

deinstall: ;@echo "-- Removing dependencies"
	rm -rf elm-stuff/
	rm -rf node_modules/

watch: ;@echo "-- watching files"
	npm run watch
