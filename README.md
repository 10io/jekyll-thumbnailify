# jekyll-thumbnailify


A Jekyll plugin to thumbnailify any image.

This plugin will read an image file from your image folder (by default 'images'), produce a thumbnail version of it and render this html
```
<a class="thumbnailify" href="/assets/foobar.png"><img src="/assets/foobar_t.png" /></a>
```

This way, you can the use any JS plugin to add easily an effect going from the thumbnail image to the real image.
For instance, you can use:

* [fancyBox 2](http://fancyapps.com/fancybox/)
* [Lightbox 2](http://lokeshdhakar.com/projects/lightbox2/)
* Many others

## Installation
* Install mini magick: `gem install mini_magic` (or use `gem "mini_magic"` in your gemfile and then `bundle install`)
* At the root of your site, if you don't have one, create a folder called `_plugins`
* Copy jekyll-thumbnailify.rb: `wget https://raw.github.com/10io/jekyll-thumbnailify/master/jekyll-thumbnailify.rb` (if you don't have wget [brew](http://mxcl.github.com/homebrew/) it)

## Usage
* At the root of your site, put all your images in a folder called _images_
* In any page of your Jekyll site, use `{% t foo.png %}` to generate the thumbnail and the link

### Notes
* the image folder name can be conigured in the \_config.yml file using the images\_directory variable
* the images\_directory can point to a subfolder, for example: images/posts
* the css class name of the generated link can be configured in the \_config.yml file using the images\_css\_class variable