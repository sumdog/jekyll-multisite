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

* Install the [jekyll-unsanitize](https://github.com/sumdog/jekyll-unsanitize) dependency.

    git clone https://github.com/sumdog/jekyll-multisite
    cd jekyll-multisite
    gem build jekyll-multisite.gemspec
    gem install jekyll-multisite-<version>.gem

Usage
-----

In your `_config.yml`, add the following section:

    ...
    gems: 
      - jekyll-multisite
    
    shared: ../_shared
    shared_pagination: true
    ...

Each individual site needs to have it's own configuration file with it's own source and destination. Let's use `_example.yml` to demonstrate:

   ...
   url: "http://example.com"
   destination: _site/example
   source: '_example'
   
Due to the way things are done internally in Jekyll, the shared source directory must be relative to to the source path. More information can be found on the [Jekyll Multi-site](http://penguindreams.org/insert-address-here) blog post.  
