#!/usr/bin/env ruby

module TitleGenerator
  ##
  # A model to represent all Hacker News titles, and generate sentences using
  # markov chains.
  class MarkovModel
    TITLES = [
      "hey ben what time does bob get here?",
      "neighbor joe bob. don't go there joe!",
      "hey, hi what's that sound?",
      "everbody knows what's going down.",
      "hi-de-ho there neighbor.",
      "go down joe!",
      "go up mike!",
      "down town!",
      "go up and down the hill.",
      "bob don't go there neighbor.",
      "joe what's going here?",
      "go does bob get that sound?",
    ]


    #SENTENCE_STUBS = [:bob, :get, :does, :time, :what, :ben, :hey, nil, :neighbor, :joe, :go, :there, :"don't", :"what's", :that, :hi, :"hey,", :going, :knows, :everbody, :"hi-de-ho", :here?, :"bob.", :joe!, :sound?, :"down.", :"neighbor."].map(&:to_s)
    SENTENCE_STUBS = [:go]
    DEFAULT_INPUT = "#{TITLES.join(' ')}|#{SENTENCE_STUBS.sample}"
    def self.help
      %Q(./title_generator.rb #{DEFAULT_INPUT}\n\n)
      # markov_model: {[:bob, :get]=>[:here?, :that], [:does, :bob]=>[:get, :get], [:time, :does]=>[:bob], [:what, :time]=>[:does], [:ben, :what]=>[:time], [:hey, :ben]=>[:what], [nil, :hey]=>[:ben], [nil, nil]=>[:hey, :neighbor, :"don't", :"hey,", :everbody, :"hi-de-ho", :go, :go, :down, :go, :bob, :joe, :go], [:neighbor, :joe]=>[:"bob."], [nil, :neighbor]=>[:joe], [:go, :there]=>[:joe!, :"neighbor."], [:"don't", :go]=>[:there, :there], [nil, :"don't"]=>[:go], [:"what's", :that]=>[:sound?], [:hi, :"what's"]=>[:that], [:"hey,", :hi]=>[:"what's"], [nil, :"hey,"]=>[:hi], [:"what's", :going]=>[:"down.", :here?], [:knows, :"what's"]=>[:going], [:everbody, :knows]=>[:"what's"], [nil, :everbody]=>[:knows], [:"hi-de-ho", :there]=>[:"neighbor."], [nil, :"hi-de-ho"]=>[:there], [:go, :down]=>[:joe!], [nil, :go]=>[:down, :up, :up, :does], [:go, :up]=>[:mike!, :and], [nil, :down]=>[:town!], [:down, :the]=>[:"hill."], [:and, :down]=>[:the], [:up, :and]=>[:down], [:bob, :"don't"]=>[:go], [nil, :bob]=>[:"don't"], [:joe, :"what's"]=>[:going], [nil, :joe]=>[:"what's"], [:get, :that]=>[:sound?], [:go, :does]=>[:bob]}
      # tokens: [:go]
      # => go does bob get here?
      # notice it's a phrase made-up of many parts, not just a direct copy!
    end

    def self.test
      from(DEFAULT_INPUT)
    end

    def self.from(giant_input_string)
      titles_in_a_string, sentence_to_complete = giant_input_string.split('|')
      titles = []
      titles_in_a_string.split(/([\.\?\!])\s+/).each_slice(2) {|title,punctuation| titles << "#{title}#{punctuation}"}
      puts "titles: #{titles.inspect}"
      puts "sentence_to_complete: #{sentence_to_complete.inspect}"
      puts TitleGenerator::MarkovModel.new(titles).complete_sentence(sentence_to_complete, min_length: 5, max_length: 20)
    end

    ##
    # Creates the ultimate buzzword generator using markov chains trained on the
    # titles found in MarkovNews::Item.titles.
    def initialize(titles=[])
      @markov_model = Hash.new { |hash, key| hash[key] = [] }
      titles.each do |title|
        tokens = tokenize(title)
        until tokens.empty?
          token = tokens.pop
          markov_state = [tokens[-2], tokens[-1]]
          @markov_model[markov_state] << token
        end
      end
      puts "markov_model: #{@markov_model.inspect}"
    end

    ##
    # Completes a sentence using the Markov Model trained on news titles.
    #
    # @param [String] sentence to be completed, empty string is acceptable
    # @param [Integer] min_length specifies the lower bound on random sentence
    #   length. The sentence may be shorter than this if a punctuation character
    #   is encountered.
    # @param [Integer] max_length specifies the upper bound on random sentence
    #   length
    # @return [String] a complete sentence according to the markov model
    def complete_sentence(sentence = '', min_length: 5, max_length: 20)
      tokens = tokenize(sentence)
      puts "tokens: #{tokens.inspect}"
      until sentence_complete?(tokens, min_length, max_length)
        markov_state = [tokens[-2], tokens[-1]]
        tokens << @markov_model[markov_state].sample
      end
      tokens.join(' ').strip
    end

    private
    ##
    # Breaks the sentence into words using spaces. Punctuation is retained as
    # parts of words so that conjunctions and sentence endings retain data.
    #
    # @param [String] sentence to tokenize
    # @return [Array<Symbol>] the tokens in the sentence
    def tokenize(sentence)
      return [] if sentence.nil? || sentence.length == 0
      sentence.split(' ').map { |word| word.downcase.to_sym } # interesting that we symbolize words with punctuation ?!
    end

    ##
    # Checks a token list to see if it forms a proper complete sentence
    #
    # @param [Array<symbol>] tokens to consider
    # @param [Integer] minimun length that qualifies a complete sentence
    # @param [Integer] maximum length of any acceptable sentence
    # @return [Boolean] whether the sentence is complete
    def sentence_complete?(tokens, min_length, max_length)
      tokens.length >= max_length || tokens.length >= min_length && (
        tokens.last.nil? || tokens.last =~ /[\!\?\.]\z/
      )
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  giant_input_string = ARGV.join(' ')
  puts "giant_input_string: #{giant_input_string.inspect}"
  if ["","test","help","--help","-?"].include?(giant_input_string)
    puts TitleGenerator::MarkovModel.help
    puts TitleGenerator::MarkovModel.test
  else
    puts TitleGenerator::MarkovModel.from(giant_input_string)
  end
end
