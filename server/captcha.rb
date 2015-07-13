require 'rubygems'
require 'RMagick'

module Captcha

  def generate_image(string)
      options = {
        :fontsize => 35,
        :width => 130,
        :height => 90,
        :color => '#000',
        :background => '#FFF',
        :fontweight => 'normal',
        :rotate => true,
        :fonts => ['Palatino', 'Times', 'NewCenturySchlbk']
      }

      options[:fontweight] = case options[:fontweight]
        when 'bold' then 700
        else 400
      end

      text = Magick::Draw.new
      text.pointsize = options[:fontsize] + rand(5)
      text.font_weight = options[:fontweight]
      text.gravity = Magick::CenterGravity
      text.fill = text.stroke = 'white'
      text.font = options[:fonts].sort_by{rand}.first if options[:fonts]
      text.text_antialias = false

      #rotate text
      text.rotation = (5 + rand(5)) * (rand() < 0.5 ? 1:-1) if options[:rotate]

      #metric = text.get_type_metrics(string)

      #add bg
      canvas = Magick::ImageList.new

      if !@bg_image or rand < 0.05
        gradient = Magick::GradientFill.new(0, 0, -10 + rand(20), -10 + rand(20), "rgb(#{255-rand(70)},#{255-rand(10)},255-#{rand(50)})", "##{rand(7)}#{rand(6)}#{rand(5)+3}")
        @bg_image = Magick::Image.new(options[:width], options[:height], gradient)
        dc = Magick::Draw.new
        dc.stroke("black")
        dc.stroke_width(15)
        r = rand(90)
        dc.line(-10, r, options[:width]+10, 90-r)
        dc.draw(@bg_image)
      end

      text_image = Magick::Image.new(options[:width], options[:height]){
        #self.image_type = Magick::GrayscaleType
        self.background_color = 'black'
      }.annotate(text, 0, 0, 0, 0, string).implode(-0.1).wave(5 + rand(5), 60 + rand(20))

      canvas << @bg_image.composite(text_image,0,0,Magick::DifferenceCompositeOp)

      if !@text2_image or rand < 0.05
        string2 = 'captchator.com'
        text2= Magick::Draw.new
        text2.pointsize = 10
        text2.fill = '#CCC'
        #metric2 = @text2.get_type_metrics(string2)
        @text2_image = Magick::Image.new(options[:width], options[:height]){
          #self.image_type = Magick::GrayscaleType
          self.background_color = '#FFF0'
        }.annotate(text2, 0, 0, 5, 10, string2)
      end

      canvas << @text2_image

      image = canvas.flatten_images #.charcoal(0.85).blur_image(1)
      image.format = 'PNG'
      #image.image_type = Magick::GrayscaleType

      raw = image.to_blob{ self.quality = 30 }
      image = nil
      canvas = nil
      text = nil
      text2 = nil
      GC.start if rand < 0.2
      raw
  end

  def generate_answer
    chars = (('2'..'8').to_a + ('a'..'z').to_a - ['o', 'd', 'l', 'g', 'q', 'm', 'n', 'h', 'i', 'j', 'u', 'e', 's', 't', 'r', '5', '7', '8']) #* 3
    chars = chars.sort_by { rand }
    s = chars[0..3].to_s
  end
end
