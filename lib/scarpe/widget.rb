class Scarpe
  class Widget
    def method_missing(name, *args, &block)
      widget = $widgets[name.to_s]

      raise NoMethodError, "no method #{name} for #{self.class.name}" unless widget

      widget_instance = widget.new(*args)

      @children ||= []
      @children << widget_instance

      widget_instance
    end

    def to_html
      if self.respond_to?(:element)
        puts "#{self} - to_html with Element"
        element do
          @children ||= []
          @children.map do |child|
            child.to_html
          end

          puts "These are the ellement children #{@children.inspect}"

          @children.join
        end
      else
        puts "#{self} - to_html no Element"
        @children ||= []
        @children.map do |child|
          child.to_html
        end.join
      end
    end
  end
end
