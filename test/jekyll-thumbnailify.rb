require 'test/unit'
require 'jekyll'
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'jekyll-thumbnailify')

class TestJekyllThumbnailify < Test::Unit::TestCase
  # Tests that the plugin registers correctly within Jekyll
  def test_register    
    tag = Liquid::Template.tags['t']
    assert_not_nil tag
    assert_equal 'Jekyll::ThumbnailifyTag', tag.to_s
  end
end