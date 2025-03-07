# frozen_string_literal: true

class Scarpe
  class Button < Scarpe::Widget
    display_properties :text, :width, :height, :top, :left

    def initialize(text, width: nil, height: nil, top: nil, left: nil, &block)
      # Properties passed as positional args, not keywords, don't get auto-set
      @text = text
      @block = block

      super

      # Bind to a handler named "click"
      bind_self_event("click") do
        @block&.call
      end

      create_display_widget
    end

    # Set the click handler
    def click(&block)
      @block = block
    end
  end
end
