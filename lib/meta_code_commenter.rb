
module MetaCodeCommenter

  def self.comment(lines, params={})
    lines = lines.split(/\n/) if lines.respond_to?(:to_str)
    Generator.new(lines, params).to_s
  end

  class Evaluator
    instance_methods.each {|m| undef_method m unless m =~ /^__/ }

    def initialize(vars)
      vars.each do |key, value|
        eval <<-RUBY
          def #{key}
            #{value.inspect}
          end
        RUBY
      end
    end

    def __eval__(line)
      eval(%{"#{line}"})
    end

    def method_missing(method, *args, &block)
      method.to_s
    end
  end

  class Generator
    include Enumerable

    def initialize(lines, params={})
      @lines = lines.map(&:chomp)
      @evaluator = Evaluator.new(params)
      @max_length = (lines.max_by(&:length) || "").length
      @max_length += 1 unless @max_length % 2 != 0
      @remove_spaces = @lines.map { |line| (line[/^\s+/] || "").length }.min
    end
    
    def generate(line)
      pad = " " * (@max_length - line.length)
      comment = " # "
      evaluated = @evaluator.__eval__(line)[@remove_spaces..-1]

      line + pad + comment + evaluated
    end

    def generate!
      @lines.map { |line| generate(line) }
    end

    def to_s
      generate!.join("\n")
    end
  end

end
