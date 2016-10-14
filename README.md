# [WONDROUS](https://www.wearewondrous.com) Drupal 8 Best Practice 2016

This is a compendium of knowledge we gathered during our trails and errors running Drupal 8 web pages.

We try to address Sitebuilder, as well as Developer. Our findings touch SEO topics as well as performance and ease of development.


## Basic assumptions

Using Drupal 8 with local, development, (stage/test) and productive environment. Using Composer. Wether you check in all your files or you compile them on the server and push it to the environment.

always name everything in one language. All your node types, all your fields, every configuration, every form key needs to be in one language (preferably english). From this you start using translations. Even if there are no other languages - stick to it.

## Default `composer.json`

Provide a standard composer file with minimal modules setup as well a `drush` install command list

- separate site builder topics, developer topics, SEO relevant hints
- specific to tooling (Acquia, PHPStorm, node)

## PHP Storm

- Install module `editorconfig` to use the Drupal own indentation.
- Install `.ignore` plugin to add default git ignore templates for OSX, drupal, node and idea files
- Set folders `sites/default/files` to „Mark directory as…“ > „excluded“ 


## Git config

Use `.gitconfig` in git root folder to set correct encoding for binary files. e.g. fonts

```
*.woff2 binary
*.woff binary
```

## Drupal Config

### Front page and redirect module

If front page is a node and the redirect module is enabled, make sure to set the checkbox „Remove trailing slashes from paths.“ Otherwise you will end up in a „Too many redirects“ error on the front page. 

![redirect setup](screens/redirect-module-config.png)

### Themes

Put your personalized themes directly under `themes`. Not `profiles`. Not `themes/custom`. This will avoid deep folder nesting. Google crawling problems.

## Drupal Modules

### Rabbit hole

You can remove or disable the Taxonomy view but your taxonomies will still be available via the url `taxonomy/term/{id}`. To prevent this use the Rabbit hole sub module `rh_taxonomy` to prevent this pages from being crawled.
If the bots have already crawled this pages, decide whether to display a 404-page or redirect to front page.


## Drupal Drush

on Drupal updates run:

```bash
$ drush @alias -y updb
$ drush @alias -y entup
$ drush @alias locale-update
$ drush @alias -v cron
```

## Acquia

- Set *dev* and *stage* environment directly to `master` branch. So only *prod* will use git Tags.
- use server side cron runs (only on prod) instead of drupal db triggered cron run

## Twig

### Fetching the value from a given field

```twig
{{ content.field_text['#items'].getString }}
instead of 
{{ content.field_text[0]['#markup'] }}
```

cycle through a list of items in a field
```twig
{% for item in content.field_text['#items'].getItterator %}
	{{ item.value }}
{% endfor %}
```

### Linking to referenced entities

You have in a teaser view an entity reference to which you want to link but with a custom anchor tag — instead of using the field template.

Go to manage display. For the referenced field set format to label and „link to the reference“

In the corresponding twig file you can then do:

```twig
<a href="{{ content.field_reference[0]['#url'] }}" class="button">
  {{ content.field_reference[0]['#title'] }}
</a>
```
 


## Styles

- Use a certain class, like `.rt`, for all content coming from rich text editors. So you style lists like `ul` and `ol` accordingly. Scoping your css.

## SEO 

- Make sure to have only one domain you serve. Otherwise redirect with `301` to the main domain.

remove trailing slashes
http://blamcast.net/articles/drupal-seo
https://yoast.com/duplicate-content/
https://www.agiledrop.com/blog/top-21-drupal-seo-modules-optimize-your-website

### Disallow `nodes` folder

In your `robots.txt` make sure you have this line

	Disallow: /node/

Note: In your `composer.json` add the `robots.txt` to the exclude information.

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

If you have (for what reason so ever) have active themes situated under the `profiles`-folder and user assets like fonts, make sure to allow them in the `robots.txt`, too.

```
Allow: /profiles/*.woff
Allow: /profiles/*.woff2
Allow: /profiles/*.eot
Allow: /profiles/*.ttf
```
