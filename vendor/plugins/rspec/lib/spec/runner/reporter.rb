module Spec
  module Runner
    class Reporter
      attr_reader :options
      
      def initialize(options)
        @options = options
        @options.reporter = self
        clear
      end
      
      def add_example_group(example_group_description)
        formatters.each{|f| f.add_example_group(example_group_description)}
        @example_group_descriptions << example_group_description
      end
      
      def example_started(example)
        formatters.each{|f| f.example_started(example)}
      end
      
      def example_finished(example, error=nil)
        @examples << example
        
        if error.nil?
          example_passed(example)
        elsif Spec::Example::ExamplePendingError === error
          example_pending(@example_group_descriptions.last, example, error.message)
        else
          example_failed(example, error)
        end
      end

      def failure(name, error)
        backtrace_tweaker.tweak_backtrace(error)
        example_name = "#{@example_group_descriptions.last} #{name}"
        failure = Failure.new(example_name, error)
        @failures << failure
        formatters.each do |f|
          f.example_failed(name, @failures.length, failure)
        end
      end
      alias_method :example_failed, :failure

      def start(number_of_examples)
        clear
        @start_time = Time.new
        formatters.each{|f| f.start(number_of_examples)}
      end
  
      def end
        @end_time = Time.new
      end
  
      # Dumps the summary and returns the total number of failures
      def dump
        formatters.each{|f| f.start_dump}
        dump_pending
        dump_failures
        formatters.each do |f|
          f.dump_summary(duration, @examples.length, @failures.length, @pending_count)
          f.close
        end
        @failures.length
      end

    private

      def formatters
        @options.formatters
      end

      def backtrace_tweaker
        @options.backtrace_tweaker
      end
  
      def clear
        @example_group_descriptions = []
        @failures = []
        @pending_count = 0
        @examples = []
        @start_time = nil
        @end_time = nil
      end
  
      def dump_failures
        return if @failures.empty?
        @failures.inject(1) do |index, failure|
          formatters.each{|f| f.dump_failure(index, failure)}
          index + 1
        end
      end
      def dump_pending
        formatters.each{|f| f.dump_pending}
      end

      def duration
        return @end_time - @start_time unless (@end_time.nil? or @start_time.nil?)
        return "0.0"
      end
      
      def example_passed(example)
        formatters.each{|f| f.example_passed(example)}
      end
      
      def example_pending(example, example_name, message="Not Yet Implemented")
        @pending_count += 1
        formatters.each do |f|
          f.example_pending(example, example_name, message)
        end
      end
      
      class Failure
        attr_reader :exception
        
        def initialize(example_name, exception)
          @example_name = example_name
          @exception = exception
        end

        def header
          if expectation_not_met?
            "'#{@example_name}' FAILED"
          elsif pending_fixed?
            "'#{@example_name}' FIXED"
          else
            "#{@exception.class.name} in '#{@example_name}'"
          end
        end
        
        def pending_fixed?
          @exception.is_a?(Spec::Example::PendingExampleFixedError)
        end

        def expectation_not_met?
          @exception.is_a?(Spec::Expectations::ExpectationNotMetError)
        end

      end
    end
  end
end
