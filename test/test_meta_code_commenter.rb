require 'helper'

class String
  def deindent
    gsub(/^\s*/, '')
  end
end

context "Generates output" do
  def asserts_output(description, input, expected, args={})
    input.chomp!
    expected.chomp!

    asserts(description) do
      MetaCodeCommenter::Generator.new(input.split(/\n/), args).to_s
    end.equals(expected)
  end

  asserts_output("empty", <<-'IN', <<-'OUT')
  IN
  OUT

  asserts_output("one line", <<-'IN', <<-'OUT')
    hello
  IN
    hello # hello
  OUT

  asserts_output("one line interpolated", <<-'IN', <<-'OUT', :value => "world")
    hello = '#{value}'
  IN
    hello = '#{value}'  # hello = 'world'
  OUT

  asserts_output("align lines", <<-'IN', <<-'OUT')
    def method_call
      method_body
    end
  IN
    def method_call # def method_call
      method_body   #   method_body
    end             # end
  OUT

  # TODO is failing!
  asserts_output("double quote", <<-'IN', <<-'OUT', :key => "hello", :value => "world")
    def #{key}
      "#{value}"
    end
  IN
    def #{key}    # def hello
      "#{value}"  #   "world"
    end           # end
  OUT

end
