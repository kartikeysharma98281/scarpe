class Scarpe
  class Stack < Scarpe::Widget
    def initialize(width:nil, margin:nil, &block)
      @width = width
      @margin = margin
      instance_eval(&block)
    end

    def background(color)
      @background = color
    end

    def element
      HTML.render do |h|
        h.div(id: html_id, style: style) { yield }
      end
    end

    private

    def style
      styles = {}

      styles[:display] = "flex"
      styles["flex-direction"] = "column"
      styles[:margin] = Dimensions.length(@margin) if @margin
      styles[:width] = Dimensions.length(@width) if @width
      styles[:background] = @background if @background

      styles
    end
  end
end
