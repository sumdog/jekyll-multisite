jekyll-multisite
=================

[![Gem](https://img.shields.io/gem/v/jekyll-multisite.svg?style=plastic)]()

Jekyll doesn't support multiple sites by default. If you want to have multiple sites with shared source code with Jekyll, you'll need to use the [jekyll-unsanitize](https://github.com/sumdog/jekyll-unsanitize) gem plus a ton of ugly symbolic links in your source tree. The following plugin adds support for a sahred base that can be used in multiple Jekyll projects.  

Dependencies
--------

* jekyll v3.0.1+

Installation
------------

To install the current release, run the following:

    gem install jekyll-multisite

To install from source:

    git clone https://github.com/sumdog/jekyll-multisite
    cd jekyll-multisite
    gem build jekyll-multisite.gemspec
    gem install jekyll-multisite-<version>.gem

Usage
-----

Each individual site needs to have it's own configuration file with it's own source and destination. Let's use `_example_com.yml` to demonstrate:

```
...
title: Example dot Com
url: http://example.com
destination: _site/example.com
source: '_example.com'
exclude: ['some-file.md']
...
```

Now, lets' create a second site as well, in a file called `_example_net.yml`

```
...
title: Example dot Net
url: http://example.net
destination: _site/example.net
source: '_example.net'
exclude: ['some-other-file.md']
...
```

Finally, we need a base `_config.yml` that declares all the settings that are shared:

```
email: nobody@example.com
baseurl: ""
paginate: 10
gems:
 - jekyll-multisite
 - jekyll-paginate

markdown: kramdown

layouts_dir: _layouts
includes_dir: _includes
plugins_dir: _plugins
shared_dir: _shared

include: ['.htaccess']

sass:
  sass_dir: _sass
  style: compressed
```

Due to the way things are done internally in Jekyll and the limitation of my plugin, the shared source directory must be one directory down from the source path. Your directory structure should look like the following:

```
.
├── _config.yml
├── _example.com
│   ├── about.md
│   ├── css
│   ├── _data
│   ├── _drafts
│   ├── favicon.ico
│   ├── files
│   ├── images
│   ├── _plugins -> ../_plugins/
│   ├── _posts
│   └── videos.html
├── _example_com.yml
├── _example.net
│   ├── about.md
│   ├── css
│   ├── _data
│   ├── _drafts
│   ├── favicon.ico
│   ├── files
│   ├── images
│   ├── _plugins -> ../_plugins/
│   ├── _posts
│   └── videos.html
├── _example_net.yml
├── _shared
│   ├── 404.html
│   ├── archives.md
│   ├── contact.md
│   ├── css
│   ├── feed.xml
│   ├── fonts
│   ├── index.html
│   └── js
├── _includes
├── _layouts
└── _plugins
```

Take care to notice you still need a symbolic link for `_plugins` to work correctly (I'm working on fixing that). When you build you sites, built them like so:

    jekyll build --config _config.yml,_example_net.yml
    jekyll build --config _config.yml,_example_com.yml

Things to note:

* Due to a bug, you still need to symbolic link `_plugins` from your base to the site source
* Watching and dynamic updating of changed to the `_shared` directory doesn't currently work
* `_shared` must be one directory below (../) the source for each website.
* If you have something in both the site source and the shared source, the shared will overwrite what is in the site source
* I had to monkey patch the pagination plugin to work with this setup. You may have to adjust other plugins for multi-site support
* The shared output is actually generated in `_site` and moved after generation is complete
* This entire plugin is very hacky and does some interesting stuff under the hood to get multi-site working. 
* Only tested on Jekyll 3.0.1. Other versions will most likely not work.
