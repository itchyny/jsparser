main.js: ./src/main.coffee
	coffee --compile $<
	mv ./src/main.js ./main.js

jsparser.js: ./src/jsparser.jison
	../jison/bin/jison $<

main.css: ./src/main.less
	lessc -x $< > $@

index.html: ./src/index.jade
	cd ./src/ && jade ./index.jade --out ..

all:
	make main.js
	make jsparser.js
	make main.css
	make index.html

release:
	coffee --compile ./src/main.coffee
	node -e "require('fs').readFile('./src/main.js',\
		'UTF-8',\
		function(e,d){\
		console.log(';');\
			require('../closure').compile(d,\
				function(e,f){\
					console.log(f+'')\
				}\
			)\
		})" > ./main.js

