# frozen_string_literal: true

class Scarpe
  module Stroke
    def self.included(includer)
      includer.display_properties :stroke_color
    end

    # Considering a signature like this:
    # stroke "#00D0FF"
    def stroke(color)
      @stroke_color = color
    end
  end
end
