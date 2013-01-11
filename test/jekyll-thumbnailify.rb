require 'test/unit'
require 'jekyll'
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'jekyll-thumbnailify')

class TestJekyllThumbnailify < Test::Unit::TestCase
  # Tests setup used to initialize stub objects
  def setup
    @site = StubSite.new
    @site.static_files = []
    @site.config = {}
    @context = StubContext.new(@site)
  end
  
  # Tests teardown
  def teardown
    @context = nil
    @site = nil
  end
  
  # Tests that the plugin registers correctly within Jekyll
  def test_register    
    tag = Liquid::Template.tags['t']
    assert_not_nil tag
    assert_equal 'Jekyll::ThumbnailifyTag', tag.to_s
  end
  
  # Tests that the plugin can be initialized correctly
  def test_initialize
    tag = Jekyll::ThumbnailifyTag.new('t', 'foobar.png', nil)
    assert_not_nil tag
    assert_equal 'foobar.png', tag.instance_variable_get('@image_file')
  end
  
  # Tests that the plugin can be initialized correctly with a wrong string
  def test_initialize_strip_name
    tag = Jekyll::ThumbnailifyTag.new('t', '    foobar.png       ', nil)
    assert_not_nil tag
    assert_equal 'foobar.png', tag.instance_variable_get('@image_file')
  end
  
  # Tests the render method
  def test_render
    tag = Jekyll::ThumbnailifyTag.new('t', 'foobar.png', nil)
    assert_not_nil tag

    html = tag.render(@context)

    assert_not_nil html
    assert_equal '<a class="image" href="/images/foobar.png"><img src="/images/foobar_t.png" /></a>', html
    file = @site.static_files.first
    assert_not_nil file
    assert file.path =~ /foobar_t.png/
  end
  
  # Tests the render method with invalid chars on the image filename
  def test_render_invalid_chars
    tag = Jekyll::ThumbnailifyTag.new('t', 'foo@bar.png', nil)
    assert_not_nil tag

    html = tag.render(@context)

    assert_not_nil html
    assert_equal "Image filename 'foo@bar.png' contains invalid characters", html
    assert_equal 0, @site.static_files.size
  end
  
  # Tests the render method with an unknown image file
  def test_render_unknown_image
    tag = Jekyll::ThumbnailifyTag.new('t', 'foobaar.png', nil)
    assert_not_nil tag

    html = tag.render(@context)

    assert_not_nil html
    assert_equal "File foobaar.png not found in images", html
    assert_equal 0, @site.static_files.size
  end
  
  # Tests the render method with custom params
  def test_render_custom_params
    tag = Jekyll::ThumbnailifyTag.new('t', 'foobar.png', nil)
    assert_not_nil tag
    @site.config['images_directory'] = 'assets'
    @site.config['images_css_class'] = 'thumbnailify'

    html = tag.render(@context)
    
    assert_not_nil html
    assert_equal '<a class="thumbnailify" href="/assets/foobar.png"><img src="/assets/foobar_t.png" /></a>', html
    file = @site.static_files.first
    assert_not_nil file
    assert file.path =~ /foobar_t.png/
  end
  
  private
  
  # The stub for the site object
  class StubSite
    attr_accessor :static_files, :config
    
    def source
      File.join '.', 'test'
    end
    
  end
    
  # The stub for the context object
  class StubContext
    def initialize(site)
      @site = site
    end
      
    def registers
      {:site => @site}
    end
  end
end