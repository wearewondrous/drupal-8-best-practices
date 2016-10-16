# [WONDROUS](https://www.wearewondrous.com) Drupal 8 Best Practice 2016

This is a compendium of knowledge we gathered during our trail and errors running Drupal 8 web pages.

We try to address sitebuilder, as well as Developer. Our findings touch SEO topics as well as performance and ease of development. Always refer to the modules current readme files first, because information on this page may be dated.


## Basic assumptions

As a setup: Drupal 8 with local development (mamp, e.g. DevDesktop), remote development, (remote stage/test) and a productive environment. Composer (e.g. [Drupal composer](https://github.com/drupal-composer/drupal-project)).

Currently we commit all our vendors and compiled filed (sass, assets, js) to the repository. A better setup would be to push only setup and sources. Then on the server download and compile everything. Finally rsync everything to the environment, if the build was successful.

### Naming things

It is a no brainer, but may it be said anyway: always name everything in one language. All your node types, all your fields, every configuration, every form key needs to be in one language (preferably english). From this you start using translations.

Even if there are no other languages - stick to it. Thinking about what a field may correctly be called in an other language makes you reflect on the actual usage.

Name field in singular and plural. Give a good clue on what the theme layer can expect from a given variable.


## Default `composer.json`

Have a look in the [`composer.json`](composer.json) in this very repository.


## PHP Storm

- Install module `editorconfig` to use the Drupal own indentation.
- Install `.ignore` plugin to add default git ignore templates for OSX, drupal, node and idea files.
- Set folders `sites/default/files` to „Mark directory as…“ > „excluded“. So the folder inspection won’t take that long after a file remote sync.

## Git config

Use the `.gitconfig` in git root folder to set correct encoding for binary files. e.g. fonts

```
*.woff2 binary
*.woff binary
```

We always had the problem of `woff2` files being encoded not correctly. So the Browser would throw warnings in the dev tools.

## Drupal Config

### Front page and redirect module

If front page is a node and the `redirect` module is enabled, make sure to set the checkbox „Remove trailing slashes from paths.“ Otherwise you will end up in a „Too many redirects“ error on the front page. 

![redirect setup](screens/redirect-module-config.png)

### Themes

Put your personalized themes directly under `themes`. Not `profiles`. Not `themes/custom`. This will avoid deep folder nesting and prevent Google crawling problems.

Have a thorough look at the `robots.txt` file in your project. To crawl your site, google needs to access all important folders and file types.

## Drupal Modules

### Rabbit hole

*Nodes*: Not every node type will have a dedicated full page view. Thus, use the module `rh_node` to prevent search engines and anonymous visitors of your site, to access those pages. As admin you can still browse this pages.

If you use translations on a multilingual site, make sure to grant access to the authors of your content. Otherwise, they will have a hard time accessing the translations overview page of a given node.

![Rabbit Hole Author access check](screens/rabbit-hole-module-author-access.png)

*Taxonomy*: You can remove or disable the Taxonomy view, but your taxonomies will still be available via the url `taxonomy/term/{id}`. To prevent this use the Rabbit hole sub module `rh_taxonomy` to prevent this pages from being crawled.

If the bots have already crawled this pages, decide whether to display a 404-page or redirect to front page. It may be helpful to have these extra pages pointing to your front page or other page.


### Entity browser

![Entity Browser Author access check](screens/entity-browser-module-access.png)

### Simple Sitemap

Using `simple_sitemap` and running a cron job from the command line may create a problem, if your cron job does not run on the very same server. Then you end up with a wrong url in the `sitemap.xml`.

To prevent this create a `docroot/sites/default/drushrc.php` with the following content:

```php
<?php
$options['uri'] = "https://www.mydomain.com/";
```

Alternately , you can run every remote `drush cron` like this:

```bash
$ drush @alias -l https://www.mydomain.com/ cron
```

## Drupal Drush



### Updates

Since we commit everything to the repository, we have the following process. After `$ composer update` and pushing everything to the servers run:

```bash
$ drush @alias -y updb
$ drush @alias -y entup
$ drush @alias locale-update
$ drush @alias -v cron
```

### Bash script

For the tasks above you can use a the little bash script in this repository called [`d8up`](d8up.sh). 

To copy it to your user folder and set it executable, run this inside the repository:

```bash
$ cp d8up.sh ~/ && chmod u+x ~/d8up.sh 
```

Then to execute a remote update:

```bash
$ ~/d8up.sh @cloud.alias
```


## Acquia

- Set *dev* and *stage* environment directly to `master` branch. So only *prod* will use git Tags.
- use server side cron runs (only on prod) instead of drupal db triggered cron run

### Git tags clean up

To delete every git tags from the year `2015` on the remote:

```bash
$ git tag -l | grep ^2015 | xargs -n 1 git push --delete origin
```

Then clean up your local git repository:

```bash
$ git tag -l | grep ^2015 | xargs git tag -d
```

## Twig

### Fetching the value from a given field

Fetching values in twig and with the Drupal 8 view modes can be quite challenging some times. So for easy field types —  instead of drilling into the render array — use the methods `getValue` or `getString` of your Types.

`getValue` will return an array with a key called `value`. Haven’t found a solid use case for that.

`getString` will return the fields values as comma separated list. Quite usefull, I think.

```twig
so use
{{ content.field_text['#items'].getString }}
instead of 
{{ content.field_text[0]['#markup'] }}
```

If you need to cycle through a list of items in a field, use the `getItterator` method:

```twig
{% for item in content.field_text['#items'].getItterator %}
	{{ item.value }}
{% endfor %}
```

### Linking to referenced entities

Example: You have an entity reference, out of which you want to build a custom anchor tag — instead of using the field template.

Go to manage display and the desired view mode. For the referenced field set the format to `label` and `link to the reference`.

Then in the corresponding twig file you can do:

```twig
<a href="{{ content.field_reference[0]['#url'] }}" class="button">
  {{ content.field_reference[0]['#title'] }}
</a>
```
 
No preprocessing needed.


### Special variables

`{{ directory }}`

## Styles

- Use a certain class, like `.rt`, for all content coming from rich text editors. So you can style lists (`ul` and `ol`) coming from rich text editors accordingly. Meaning: Scoping your css.


## Scripts

Place your `node_modules` in the repository root folder. So your `grunt` and `gulp` etc. files as well.

For `grunt` pointing to an other folder use:

```js
grunt.file.setBase('docroot/themes/my_theme');
```

For `gulp` add this to the top:

```js
process.chdir(yourDir);
var gulp = require('gulp');
```

Drupal behaviors

## Fonts

Include fonts into your own theme. Don’t use the CDN because the caching may be hurting your page speed. Thus Include the `style` definitions directly as a block in the head

and before the closing `</body>`

```html
<link rel="stylesheet" href="//fast.fonts.net/t/1.css?apiType=css&projectid=123456" media="all">
```


## SEO 

- Make sure to have only one domain you serve. Otherwise redirect with `301` to the main domain.
- If your content manager are not bound to modules like `pathauto` for url generation: URLs should be preferably in lowercase. As a separator Google favors dashes (`-`) instead of underscores (`_`) or dots (`.`). Definitely avoid using empty spaces (will be converted to `%20`).
- If the style of your headlines are uppercase, make sure to teach the content Manager to NOT provide the Headline in UPPERCASE in the backend. Eventually, your content will be scraped and presented in other places (e.g. social media) without your own styling. Then the correct typography is important.
- Force language folders and redirect to them. Remove trailing slashes. See `redirect` module and set language prefix for every language (e.g. `www.mydomain.com/en`). Trailing slashes may produce duplicate content warnings.

### Disallow `nodes` folder

In your `robots.txt` make sure you have this line, to prevent search engines to crawl your „ugly“ urls. *Always* use pretty url structures not longer than around `70` characters.

	Disallow: /node/

Note: In your `composer.json` add the `robots.txt` like your `.htacces` to the exclude information.

```json
"drupal-scaffold": {
  "excludes": [
    ".htaccess",
    "robots.txt"
  ]
}
````

Further readings:

- [Drupal, duplicate content, and you](https://www.lullabot.com/articles/drupal-duplicate-content-and-you)
- http://blamcast.net/articles/drupal-seo


## Themes under `profiles`

If you (for any reason what so ever) have active themes situated under the `profiles`-folder and user assets like fonts, make sure to allow them in the `robots.txt`, too.

```
Allow: /profiles/*.woff
Allow: /profiles/*.woff2
Allow: /profiles/*.eot
Allow: /profiles/*.ttf
```

Preferably move them away from there.

—

## Further links

http://blamcast.net/articles/drupal-seo

https://yoast.com/duplicate-content/

https://www.agiledrop.com/blog/top-21-drupal-seo-modules-optimize-your-website
