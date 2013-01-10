require 'mini_magick'
require 'tempfile'

module Jekyll

  #
  # This Liquid tag take an image file, generate a thumbnail image and 
  # generate the html code to display the thumbnail as a link for the
  # image.
  # 
  # Usage: {% t foo.png %}
  # Let $image_dir be the directory where foo.png is.
  # This plugin will generate a thumbnail(160x240) foo_t.png in
  # $image_dir.
  # It will then return this html:
  # <a class="image" href="/$image_dir/foo.png">
  #  <img src="/$image_dir/foo_t.png" />
  # </a>
  #
  # The following configuration variables are read by this tag
  # images_directory    The directory where all the images are.
  #                     Set to "images" by default. This variable
  #                     accepts paths like "assets/posts/images"
  # images_css_class    The html class in the thumbnail link.
  #                     Set to "image" by default.
  #
  #
  # This tag requires RMagick to work properly.
  # Do not use image names with spaces
  class ThumbnailifyTag < Liquid::Tag
    
    # to use tempfiles in Ruby, we have to keep a reference on them.
    # otherwise, they will be removed by the garbage collector.
    # This array keeps all the refs on tempfiles, so tempfiles are 
    # deleted only when the Ruby process ends.
    @@tempfiles = []
    
    # Default constructor
    def initialize(tag_name, file, tokens)
      super
      @image_file = file.strip
    end

    # Called by Liquid to render this tag
    def render(context)
      # validate image filename
      if @image_file !~ /^[a-zA-Z0-9_\/\.-]+$/ || @image_file =~ /\.\// || @image_file =~ /\/\./
        return "Image filename '#{@image_file}' contains invalid characters or sequences"
      end
      
      # get the images directory
      site = context.registers[:site]
      image_folder = site.config['images_directory'] || 'images'
      
      # read image source
      image_src_path = File.join(site.source, image_folder, @image_file)
      if(File.file?(image_src_path))
        
        # generate the thumbnail
        thumbnail_ext = File.extname(image_src_path)
        thumbnail_name = File.basename(image_src_path, thumbnail_ext) + '_t' + thumbnail_ext
        thumbnail = generate_thumbnail(image_src_path, thumbnail_name)
        
        # generate jekyll static file
        static_file = ImageStaticFile.new(thumbnail, image_folder, thumbnail_name)
        site.static_files << static_file
        
        
        # generate the html part
        html_class = site.config['images_css_class'] || 'image'
        "<a class=\"#{html_class}\" href=\"#{urlize(image_folder, @image_file)}\"><img src=\"#{urlize(image_folder, thumbnail_name)}\" /></a>"
        
      else
        # the target image file doesn't exist
        return "File #{@image_file} not found in #{image_folder}"
      end
    end
    
    private
    
    # Generate a thumbnail image from the given image in a temporary
    # file.
    #   +image_path+ is the path to the source image
    #   +thumbnail_name+ is the name of thumbnail(extension included)
    #
    # Returns the path of the temporary file
    def generate_thumbnail(image_path, thumbnail_name)
      # generate thumbnail file
      image_src = MiniMagick::Image.open(image_path)
      image_src_ext = File.extname(image_path)
      image_dest = Tempfile.new(thumbnail_name)
      
      # generate the thumbnail with RMagick
      image_src.resize '160x240'
      image_src.write image_src_ext[1 .. -1] + ':' + image_dest.path
      # store the reference of the tempfile
      @@tempfiles << image_dest
      image_dest.path
    end
    
    # Given a file path, this method will transform it in a url path.
    # Eg. \dir1\dir2\foo.txt -> /dir1/dir2/foo.txt
    # +path+ the array of multiple paths
    # 
    # Returns the html path of all given paths joined
    def urlize(*path)
      url = path.join('/')
      url = path[-1, 1] == '/' ? url : '/' + url
      url.split(File::SEPARATOR).join('/')
    end
  end
  
  # The image static file model understood by Jekyll
  # This is a sub class of StaticFile. But instead of managing a unique
  # name between the src file and the dest file, we have a src complete 
  # path, a dest path and a dest file name.
  class ImageStaticFile < StaticFile
    # Initialize a new StaticFile.
    #   +image_src+ is the complete path of the src image file. Eg. /foo/bar.png
    #   +image_dest_dir+ is the destination dir for the dest image file
    #   +image_dest_name+ is the String filename of the dest image file
    #
    # Returns <ImageStaticFile>
    def initialize(image_src, image_dest_dir, image_dest_name)
      @image_src = image_src
      @dir = image_dest_dir
      @name = image_dest_name
    end

    # Obtains source file path.
    # In this implementation, simply returns image_src
    def path
      File.join(@image_src)
    end
    
  end

end

# register this tag with Liquid
Liquid::Template.register_tag('t', Jekyll::ThumbnailifyTag)
