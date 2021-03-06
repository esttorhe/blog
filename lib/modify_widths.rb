require 'cgi'
require 'middleman-core'
require 'nokogiri'

# Wraps the given HTML in a row/wide col span, and places it outside the usual row/col span.
# Only meant to be used in a blog post.
#
# Usage: surround anything you want wider or narrower with BEGIN_(WIDE|NARROW) and END_(WIDE|NARROW).
# Example:
#
# BEGIN_WIDE
#
# ![](/awesome/pic.jpg)
#
# END_WIDE
#
# This is a simple regex-based text replacement that happens at the end of the rendering pipeline.
module ModifyWidths
  class << self

    def registered(app, options={})

      app.after_render do |body, path, locs, template_class|

  def make_wide (contents)
    <<-EOS
  </div>
</div>

<div class="row">
  <div class="col-lg-10 col-lg-offset-1 col-md-12">
    #{ contents }
  </div>
</div>

<div class="row">
  <div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">
EOS
  end

  def make_narrow (contents)
    <<-EOS
  </div>
</div>

<div class="row">
  <div class="col-lg-6 col-lg-offset-3 col-md-12">
    #{ contents }
  </div>
</div>

<div class="row">
  <div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">
EOS
  end
        
        # There are multiple rendering calls and we want to get the one that renders the blog_post template. 
        if (path.to_s.index "blog_post") != nil

          wides = body.scan(/<p>BEGIN_WIDE<\/p>(.*?)<p>END_WIDE<\/p>/m).flatten

          wides.each do |wide|
            modified = make_wide(wide)
            body.gsub!(wide, modified)
          end

          body.gsub!(/<p>(BEGIN|END)_WIDE<\/p>/, '')

          narrows = body.scan(/<p>BEGIN_NARROW<\/p>(.*?)<p>END_NARROW<\/p>/m).flatten

          narrows.each do |narrow|
            modified = make_narrow(narrow)
            body.gsub!(narrow, modified)
          end

          body.gsub!(/<p>(BEGIN|END)_NARROW<\/p>/, '')

        end
        
        body
      end
    end

    alias :included :registered
  end

end

::Middleman::Extensions.register(:modify_widths) do
  ::ModifyWidths
end
