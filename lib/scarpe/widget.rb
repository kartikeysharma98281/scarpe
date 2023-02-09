# frozen_string_literal: true

# Scarpe::Widget
#
# Interface:
# A Scarpe::Widget defines the "element" method to indicate that it has custom markup of
# some kind. A Widget with no element method renders as its children's markup, joined.

class Scarpe
  class Widget
    class << self
      attr_accessor :widget_classes

      # rubocop:disable Style/ClassVars
      def window=(w)
        @@window = w
      end

      def document_root=(app)
        @@document_root = app
      end
      # rubocop:enable Style/ClassVars

      def inherited(subclass)
        self.widget_classes ||= []
        self.widget_classes << subclass
        super
      end

      def dsl_name
        n = name.split("::").last.chomp("Widget")
        n.gsub(/(.)([A-Z])/, '\1_\2').downcase
      end
    end

    attr_reader :parent

    def initialize(*args)
    end

    def method_missing(name, *args, **kwargs, &block)
      klass = Widget.widget_classes.detect { |k| k.dsl_name == name.to_s }

      super unless klass

      ::Scarpe::Widget.define_method(name) do |*args, **kwargs, &block|
        widget_instance = klass.new(*args, **kwargs, &block)

        unless klass.ancestors.include?(Scarpe::TextWidget)
          add_child(widget_instance)
          # If we add a child, we need to redraw ourselves
          needs_update!
        end

        widget_instance
      end

      send(name, *args, **kwargs, &block)
    end

    def respond_to_missing?(name, include_all = false)
      klass = Widget.widget_classes.detect { |k| k.dsl_name == name.to_s }

      !klass.nil? || super(name, include_all)
    end

    attr_writer :parent

    def remove_child(child)
      unless @children.include?(child)
        puts "remove_child: no such child(#{child.inspect}) for parent(#{parent.inspect})!"
      end
      @children.delete(child)
      child.parent = nil
    end

    def add_child(child)
      @children ||= []
      @children << child
      child.parent = self
    end

    def html_id
      object_id.to_s
    end

    def to_html
      @children ||= []
      child_markup = @children.map(&:to_html).join
      if respond_to?(:element)
        element { child_markup }
      else
        child_markup
      end
    end

    def bind(handler_function_name, &block)
      @@document_root.bind(html_id + "-" + handler_function_name, &block)
    end

    def inner_text=(new_text)
      @@window.eval("document.getElementById(#{html_id}).innerText = \"#{new_text}\"")
    end

    def value_text=(new_text)
      @@window.eval("document.getElementById(#{html_id}).value = #{new_text}")
    end

    # Removes us from the JS DOM only, not the Ruby DOM
    def remove_self
      @@window.eval("document.getElementById(#{html_id}).remove()")
    end

    def destroy_self
      remove_self
      @parent&.remove_child(self)
    end

    # In theory, this can record which specific widgets need update and only update them.
    # Right now we're not carefully tracking which widget made which changes, so it's not
    # really safe to do limited partial redraws. The performance isn't going to be a
    # problem until we have some larger apps.
    def needs_update!
      return if @dirty # Already dirty - nothing changed, so do nothing

      @dirty = true
      @@document_root.request_redraw!
    end

    # When we do an update, we need to not redraw until we see another change
    def clear_needs_update!
      @dirty = false
      @children.each(&:clear_needs_update!)
    end

    def handler_js_code(handler_function_name, *args)
      js_args = ["'#{html_id}-#{handler_function_name}'", *args].join(", ")
      "scarpeHandler(#{js_args})"
    end
  end
end
