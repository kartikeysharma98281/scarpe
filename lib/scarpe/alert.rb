# frozen_string_literal: true

class Scarpe
  class Alert < Scarpe::Widget
    display_property :text

    def initialize(text)
      @text = text

      super

      bind_self_event("click") do
        destroy_self
      end

      create_display_widget
    end
  end
end
