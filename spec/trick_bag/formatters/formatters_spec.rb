require_relative '../../spec_helper'

require 'date'
require 'trick_bag/formatters/formatters'

module TrickBag

describe Formatters do

  context ".duration_to_s" do

    specify "it will not permit a non-number" do
      expect(->() { Formatters.duration_to_s([])}).to raise_error
    end

    expect_output_for_input = ->(expected_output, input) do
      description = "it returns '#{expected_output}' for an input of #{input}"
      specify description do
        expect(Formatters.duration_to_s(input)).to eq(expected_output)
      end
    end

    # Positive numbers
    expect_output_for_input.('1 s',                    1)
    expect_output_for_input.('1 m, 0 s',              60)
    expect_output_for_input.('3 m, 37 s',              3 * 60 + 37)
    expect_output_for_input.('1 h, 0 m, 0 s',         60 * 60)
    expect_output_for_input.('1 d, 0 h, 0 m, 0 s',    24 * 60 * 60)

    # Negative numbers
    expect_output_for_input.('-1 s',                    -1)
    expect_output_for_input.('-1 m, 0 s',              -60)
    expect_output_for_input.('-3 m, 37 s',             -(3 * 60 + 37))
    expect_output_for_input.('-1 h, 0 m, 0 s',         -60 * 60)
    expect_output_for_input.('-1 d, 0 h, 0 m, 0 s',    -24 * 60 * 60)

    # Zero
    expect_output_for_input.('0 s',                    0)

  end


  context ".end_with_nl" do

    specify "it returns an empty string for an empty string" do
      expect(Formatters.end_with_nl('')).to eq('')
    end

    specify "it leaves a single new line unchanged" do
      expect(Formatters.end_with_nl("\n")).to eq("\n")
    end

    specify "it returns an empty string for nil because nil.to_s == ''" do
      expect(Formatters.end_with_nl(nil)).to eq('')
    end

    specify "it converts a number and then adds a new line" do
      expect(Formatters.end_with_nl(3)).to eq("3\n")
    end
  end


  context ".replace_with_timestamp" do

    let(:a_date) { DateTime.new(2000, 1, 2, 15, 44, 37) }

    specify "returns the correct string" do
      s = Formatters.replace_with_timestamp('*', '*', a_date)
      expect(s).to eq('2000-01-02_15-44-37')
      #regex = /^\d\d\d\d-\d\d-\d\d-\d\d-\d\d-\d\d$/
      #puts s
      #expect(regex === s).to eq(true)
      #
      #
    end
  end


  context ".dos2unix" do

    specify "strings not containing line endings remain unchanged" do
      strings = ['', 'abc', ' ']
      expect(strings.map { |s| Formatters.dos2unix(s) }).to eq(strings)
    end

    specify "CR characters are stripped" do
      expect(Formatters.dos2unix("foo\r\nbar\r\n")).to eq("foo\nbar\n")
    end

    specify "a bad strategy will result in a raised error" do
      expect(->() { Formatters.dos2unix('', :not_a_strategy) }).to raise_error
    end
  end

  context ".dos2unix!" do

    context ':remove_all_cr' do
      specify "strings not containing line endings remain unchanged" do
        expect(Formatters.dos2unix('', :remove_all_cr)).to    eq('')
        expect(Formatters.dos2unix(' ', :remove_all_cr)).to   eq(' ')
        expect(Formatters.dos2unix('abc', :remove_all_cr)).to eq('abc')
      end

      specify "CR characters are stripped" do
        s = "foo\r\nbar\r\n"
        Formatters.dos2unix!(s, :remove_all_cr)
        expect(s).to eq("foo\nbar\n")
      end
    end

    context 'remove_cr_in_crlf' do

      specify "strings not containing line endings remain unchanged" do
        expect(Formatters.dos2unix('', :remove_cr_in_crlf)).to    eq('')
        expect(Formatters.dos2unix(' ', :remove_cr_in_crlf)).to   eq(' ')
        expect(Formatters.dos2unix('abc', :remove_cr_in_crlf)).to eq('abc')
      end

      specify "cr is replaced only in crlf" do
        s = "\rfoo\r\nbar\r\n\r"
        expect(Formatters.dos2unix(s, :remove_cr_in_crlf)).to eq("\rfoo\nbar\n\r")

      end
    end


    context 'array_as_multiline_string' do
      specify 'string representation is correct when array is NOT empty' do
        array = [1, 2, 3]
        expect(Formatters.array_as_multiline_string(array)).to eq("1\n2\n3\n")
      end

      specify 'string representation is correct when array is empty' do
        array = []
        expect(Formatters.array_as_multiline_string(array)).to eq("")
      end
    end


    context 'array_diff' do
      specify 'text is correct' do
        a1 = [1, 2, 3]
        a2 = [   2, 3, 4]
        actual_text = Formatters.array_diff(a1, a2, :color)
        expected_text = "-1\n 2\n 3\n+4\n"
        expect(actual_text).to eq(expected_text)
        puts
        puts actual_text
        puts
      end
    end
  end

end
end
