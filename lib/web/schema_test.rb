require File.join(__dir__, "../test_helper")

module Web
  class SchemaTest < Minitest::Test
    Body = Schema.build(
      type: String,
      payload: { players: [String], state: {} },
      callback: Schema.either(nil, { url: String, authorization: String }),
    )

    def ok?(payload, schema)
      payload == schema[payload]
    rescue Schema::Error
      false
    end

    def test_without_callback
      payload = { type: "potato", payload: { players: [], state: {} }, callback: nil }

      assert ok?(payload, Body)
    end

    def test_with_callback
      payload = {
        type: "potato",
        payload: { players: [], state: {} },
        callback: { url: "ohno", authorization: "ohyes" },
      }

      assert ok?(payload, Body)
    end

    def test_with_wrong_payload
      payload = {
        type: "potato",
        payload: { players: [], state: {} },
        callback: { url: "ohno", authorization: 1 },
      }

      refute ok?(payload, Body)
    end

    def test_array
      schema = Schema.build([Numeric])

      assert ok?([], schema)
      assert ok?([1], schema)
      refute ok?(nil, schema)
      refute ok?(1, schema)
      refute ok?({}, schema)
      refute ok?("", schema)
      refute ok?(["1"], schema)
    end

    def test_string
      schema = Schema.build(String)

      assert ok?("", schema)
      assert ok?("hello", schema)
      refute ok?(nil, schema)
      refute ok?(1, schema)
      refute ok?({}, schema)
      refute ok?([], schema)
      refute ok?(["1"], schema)
    end

    def test_either
      schema = Schema.build(Schema.either("potato", "carrot"))

      assert ok?("potato", schema)
      assert ok?("carrot", schema)
      refute ok?("tomato", schema)
      refute ok?("", schema)
      refute ok?(nil, schema)
    end
  end
end
