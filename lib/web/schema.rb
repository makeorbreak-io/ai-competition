module Web
  class Schema
    def self.either(*options)
      Either.new(options)
    end

    class Error < StandardError; end

    class Either
      attr_accessor :options
      def initialize(options)
        self.options = options
      end
    end

    def self.build(definition)
      ->(validatee) do
        errors = validate(definition, [""], validatee)

        if errors.any?
          raise Error, errors.join("\n")
        else
          validatee
        end
      end
    end

    def self.error(path, expectation, actual)
      [Error.new("Expected #{path.join(".")} to #{expectation}, got #{actual}")]
    end

    def self.validate(definition, path, validatee)
      case definition
      when Hash
        if !validatee.is_a?(Hash)
          error(path, Hash, validatee.class)
        elsif validatee.keys.sort != definition.keys.sort
          error(path, "have keys #{definition.keys.sort}", validatee.keys.sort)
        else
          definition.flat_map do |key, v|
            validate(v, path + [key], validatee[key])
          end
        end
      when Array
        if !validatee.is_a?(Array)
          error(path, Array, validatee.class)
        else
          validatee.each_with_index.flat_map do |v, key|
            validate(definition.first, path + [key], v)
          end
        end
      when Class
        if !validatee.is_a?(definition)
          error(path, definition, validatee.class)
        else
          []
        end
      when Schema::Either
        if definition.options.any? { |x| validate(x, path, validatee).empty? }
          []
        else
          error(path, definition.options.map(&:inspect).join(", "), validatee.inspect)
        end
      when Proc
        definition.call(path, validatee)
      else
        if validatee != definition
          error(path, definition.inspect, validatee.inspect)
        else
          []
        end
      end
    end
  end
end
