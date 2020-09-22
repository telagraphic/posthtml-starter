# About
NPM scripts driven static site starter with PostHTML & PostCSS setup along with dev and build workflows

## PostHTML
Check out [PostHTML](https://posthtml.org/#/) for more info and check out the list of dope [packages](https://posthtml.org/#/packages).

- [PostHTML](https://github.com/posthtml/posthtml)
- [Configure PostHTML from Package.json](https://github.com/posthtml/posthtml-load-config)
- [Include modules like a Static Site Generator](https://github.com/posthtml/posthtml-modules)
- [W3C Validator](https://github.com/posthtml/posthtml-w3c)



## TL;DR

Setup a simple and basic 'static site generator' with html includes, markup linting, live reload and a build process with PostHTML plugins.
Also convert BEM markup into HTML, html classes to CSS code and handy favicon generator.

## Guide

For simple static site development and even **node.js express** development,
using NPM as my build tool and task runner is my go to setup.

I've just learned about [PostCSS](https://github.com/postcss/postcss) which has about **23K** stars on github.
It isn't just a SASS replacement, it allows you to do so many cool things which I'll cover in the next blog post.

After updating my [static site starter repo](https://github.com/telagraphic/static-site-starter) by replacing **node-sass** with
**postCSS** I soon learned about [PostHTML](https://posthtml.org).

With only **2.4K** stars, this tool was the missing component to my workflow.  In this post I'll cover
getting started with **NPM** build scripts and setting up **postHTML** to do templating, linting, minification and
some other things.  Checkout my first post on working with NPM if you are unfamiliar with using NPM as a build tool.

### About

**PostHTML** is similar to **PostCSS** in that it takes raw HTML and parses it into a [AST](https://github.com/posthtml/posthtml-parser) by way of JSON.  You then modify and transform the HTML AST with [plug-ins](https://github.com/posthtml/posthtml#plugins).  There are several middleware packages for express, hapi and koa as well for server side development.

While tools like Jekyll and Elevnty do many of these things for us, **PostHTML** allows developers to build their own workflow using a plug-in based approach.

In my case, I've been looking for a way that allows HTML includes much like a standard **static site generator**.
I dont' want to learn another **SSG** and have to learn the in's and out's of it.

The idea of rolling my own custom setup is more appealing and fun.  Plus, there are tools that make it a relative breeze.
**SSG** provide many more features and tools but for my approach I want to keep complexity minimal by design.

### Setup

One advantage with **PostHTML** is running the configuration process from your package.json file itself.
[posthtml-load-config](https://github.com/posthtml/posthtml-load-config) provides several options to auto load plugins, I'll be using the package.json approach since this whole article is about NPM.

I will be using one directory called html with our templates and final rendered pages that will be used for publishing the final site.

- html
  - pages
  - templates
    - views
    - components

Let's install posthtml and some plugins to get started.

```
npm i -D posthtml posthtml-cli posthtml-load-config
```

I preface my scripts with dev for development.

```
"dev:html": "posthtml 'html/templates/views/*.html' -o html/pages",
```

Finally, let's add a posthtml object to the package.json.
The plugins object will run your installed posthtml plugins in the order they are listed.

```
"posthtml": {
  "plugins": {
    ...
  }
}
```

### Includes

PostHTML makes includes and modules trivial.  Let's see how easy this is to setup.
There are two packages that provide this functionality, [posthtml-modules](https://github.com/posthtml/posthtml-modules) and [posthtml-include](https://github.com/posthtml/posthtml-include).  

```
npm i -D posthtml-modules
```

You simple add a custom tag with a path to the to html file you want to be rendered into the page.
Notice that the path is absolute from the project root, not relative from the file.

```
<module href="html/templates/components/head.html"></module>
```

The code below will render the head.html contents into our index.html.


```
<!doctype html>
<html class="no-js" lang="en" dir="ltr">

<module href="html/templates/components/head.html"></module>

<body class="page">

  <header class="page__header">
    <h1>Home Page</h1>
  </header>
  <main class="page__main"></main>
  <footer class="page__footer"></footer>


  <noscript>
    <link rel="stylesheet" href="css/styles.css"></noscript>

</body>
<script src="js/scripts.js"></script>

</html>
```

And finally, let's add the plugin to our package.json.

```
"posthtml": {
  "from": "templates/views/*.html",
  "to": "html/pages",
  "plugins": {
    "posthtml-modules": {
      "root": "html/views"
    }
  }
},
```


Now let's run the dev:html command to compile our html.

```
npm run dev:html
```

### Watch for changes

We'll be using browser-sync and onchange to reload our changes when we make an edit and hit the save command.
dev:watch will watch for changes specifically within the html/templates directory and not the entire html folder.

[Browser-Sync](https://www.npmjs.com/package/browser-sync) handles the live reloading and syncs across multiple browsers.
This tool alone will save you so much time and clicks.  

Our dev:html command from above compiles the final html to 'html/pages'.
We will serve our static files from this directory by using -ss and passing our path.
The --files flag will watch for changes and live reload the browser when a change is detected.
--no-notify and will display a notice message when updated and --no-open will not open a new browser.

```
"dev:watch": "onchange 'html/templates' -- run-p dev:html",
"dev:server": "browser-sync start --server --ss 'html/pages' --files 'html/templates/**/*.html' --no-notify --no-open",
```

### Watch out for endless loops

I found that if I watched the entire html folder that onchange would invoke an endless loop in my console.
The dev:html command is run anytime a change is made.  New html is generated in the /pages folder.  
When the output is generated, onchange would see this as a change event and fire the dev:html command again ad infinitum.
This requires a little structure and specificity in your build scripts, which ain't a bad thing.

```
"dev:watch": "onchange 'html' -- run-p dev:html" // will cause onchange to run in an endless loop
```

### Linting and Validating

At this point, we have two paths to take.  Keep adding plugins to our posthtml configuration or separate things into
different build steps within our scripts section to be executed at a specific time or need.
We can lint our html as we develop and validate before we build our code into the /dist.
In other words, we don't need to validate our html against W3C every single time only when we are ready to publish.

Let's install the [posthtml-hint](https://github.com/posthtml/posthtml-hint) package to lint our html in the dev workflow.

```
npm i -D posthtml-hint
```

```
"posthtml": {
  "from": "templates/views/*.html",
  "to": "html/pages",
  "plugins": {
    "posthtml-modules": {
      "root": "html/views"
    },
    "posthtml-hint": {}
  }
}
```

When we run dev:html, the linter output is shown in the console.


We can use [posthtml-w3c](https://github.com/posthtml/posthtml-w3c) to
validate our html against the W3C validator.  

```
npm i -D posthtml-w3c
```

We'll create a specific build step in our scripts section that calls the [posthtml-cli](https://www.npmjs.com/package/posthtml-cli)
using the --use flag with the posthtml-w3c.


```
"build:html-validate": "posthtml 'html/pages/*html' --use posthtml-w3c"
```

### HTML to Classes

Ever write a page of markup only to have to recreate it with CSS?
There are handy [web tools](https://htmltocss.github.io/) that will convert your markup to CSS.
Or you can just run it from your command line with [posthtml-classes](https://github.com/rajdee/posthtml-classes).

In the utilities/html-css.js there is this code:

```
const fs = require('fs');
const posthtml = require('posthtml');
const config = {
        fileSave: true,
        filePath: 'css/index.css', // change css output name
        overwrite: true,
        eol: '\n',
        nested: true,
        curlbraces: true,
        elemPrefix: '__',
        modPrefix: '_',
        modDlmtr: '_'
    }

// target the file to parse
const html = fs.readFileSync('html/templates/views/index.html');


posthtml()
    .use(require('posthtml-classes')(config))
    .process(html);
```

This will output nested SASS like CSS with ampersands and all.  Checkout the css/index.css for what it looks like.
I added a NPM command as well, just make sure to change paths and filenames in the script before running.

```
"html:css": "node utilities/html-css.js"
```

### BEM

[BEM](https://en.bem.info/methodology/) or Block__Element--Modifier is a naming method for writing modular CSS.  BEM is
an approach to writing maintainable CSS and is what I'm using at the current moment, so skip over if not interested.

The [posthtml-bem](https://github.com/rajdee/posthtml-bem) will convert some special html markup into plain html with the BEM class structure.
With some special syntax like below:

```
<body block="page">

  <header elem="header">
    <h1>PostHTML Classes</h1>
  </header>
  <main elem="main">

  </main>
  <footer elem="footer"></footer>


  <noscript>
    <link rel="stylesheet" href="css/styles.css">
  </noscript>
</body>
```

Then becomes:

```
<body class="page">

  <header class="page__header">
    <h1>PostHTML Classes</h1>
  </header>
  <main class="page__main">

  </main>
  <footer class="page__footer"></footer>


  <noscript>
    <link rel="stylesheet" href="css/styles.css">
  </noscript>
</body>
```

I can see a workflow like this:

1.) Write html using BEM markup and compile to regular HTML with posthtml-bem,
2.) Convert markup to CSS structure with above posthtml-classes script
3.) Make changes to new markup and styles as needed

This could be helpful when first starting out on a project where you doing more markup coding and figuring things out.
I usually do a rewrite at least 1-3 times before I have settled on my final structure.
The above workflow can be helpful once you get used to it. Definitely follows in the steps of DRY.

You could totally run this process with onchange to compile BEM markup to HTML but you would need to modify bem.js to be dynamic and watch the bem/ directory to compile.
Sounds like another posthtml plugin potential.

### Favicons

You always need favicons and [posthtml-favicons](https://github.com/mohsen1/posthtml-favicons) has got you covered with extensive configuration options.
With default settings enabled you will tons of favicon sizes for all types of sources.  You do not need them all, so spend some time to select those you need.

### Build Steps

Cool, we learned some really awesome features of posthtml and improved our dev workflow along the way.
Let's publish our site.

I tried using [posthtml-minifier](https://github.com/Rebelmail/posthtml-minifier) but it didn't work for some reason.  It is basically a wrapper around [html-minifier](https://github.com/kangax/html-minifier).
We simply create a dist folder with some directories for our files, minify our html files and copy them into /dist.

We can run all the build steps in serial with the run-s command.

```
"build:dist": "mkdir -p dist/{css,js,img,fonts/web}",
"build:html-validate": "posthtml 'html/pages/*html' --use posthtml-w3c",
"build:minify": "html-minifier --input-dir html/pages --output-dir dist --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-tag-whitespace",
"build:html-dist": "npm run dev:html && cp html/pages/*.html dist",
"build": "run-s build:*"
```


### Next Level

In terms of performance, the next level would be to uglify CSS classnames and ID's but that is bit cumbersome and tedious with my current setup.
While def not necessary, it can only help with site speed.  This shows where rolling your own build tool begins to breakdown.  Webpack provides packages that do this.
