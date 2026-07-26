# frozen_string_literal: true

# Regression: MTVEC_BASE_ALIGNMENT_* enums claim power-of-two values.
# Catches the historical 4095 typo (should be 4096).

require "yaml"
require "minitest/autorun"

class TestMtvecBaseAlignmentPow2 < Minitest::Test
  ROOT = File.expand_path("../../../../../", __dir__)
  FILES = [
    "spec/std/isa/param/MTVEC_BASE_ALIGNMENT_DIRECT.yaml",
    "spec/std/isa/param/MTVEC_BASE_ALIGNMENT_VECTORED.yaml"
  ].freeze

  def test_enum_values_are_powers_of_two
    FILES.each do |rel|
      path = File.join(ROOT, rel)
      doc = YAML.load_file(path)
      enum = doc.dig("schema", "enum")
      refute_nil enum, "#{rel}: missing schema.enum"
      enum.each do |v|
        assert v.is_a?(Integer) && v.positive?, "#{rel}: non-positive #{v}"
        assert_equal 0, v & (v - 1), "#{rel}: #{v} is not a power of 2"
      end
      # Specific regression: 4096 present, 4095 absent
      refute_includes enum, 4095, "#{rel}: 4095 must not appear (not a power of 2)"
      assert_includes enum, 4096, "#{rel}: 4096 must be present"
    end
  end
end
