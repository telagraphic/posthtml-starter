mkdir -p {css,html,js,img}
cd css && mkdir {base,config,objects,globals,components,utilities,pages}
touch styles.css
cd ..

cd js && touch scripts.js && echo "console.log('scripts.js is working');" > scripts.js && cd ..
cd html && mkdir -p {pages,templates}
cd templates && mkdir -p {views,components}
cd views && touch index.html && cd ../../..
touch README.md

npm init -y
npm i -D posthtml posthtml-cli posthtml-load-config html-minifier posthtml-modules posthtml-w3c posthtml-hint posthtml-classes posthtml-bem posthtml-favicons browser-sync npm-run-all onchange

git init
touch .gitignore
echo "node_modules/" >> .gitignore
echo "**/.DS_Store" >> .gitignore
