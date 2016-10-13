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

## Drupal Drush

on Drupal updates run:

```bash
drush @alias -y updb
drush @alias -y entup
drush @alias locale-update
drush @alias -v cron
```

## Acquia

- Set *dev* and *stage* environment directly to `master` branch. So only *prod* will use git Tags.
- use server side cron runs (only on prod) instead of drupal db triggered cron run