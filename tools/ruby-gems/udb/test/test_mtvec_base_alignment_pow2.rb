# typed: false
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# frozen_string_literal: true

require_relative "test_helper"

require "yaml"

# Regression: MTVEC_BASE_ALIGNMENT_* enums claim power-of-two values.
# Catches the historical 4095 (0xfff) typo (should be 4096 / 0x1000).

class TestMtvecBaseAlignmentPow2 < Minitest::Test
  # tools/ruby-gems/udb/test -> repo root
  REPO_ROOT = File.expand_path("../../../../", __dir__)
  FILES = [
    "spec/std/isa/param/MTVEC_BASE_ALIGNMENT_DIRECT.yaml",
    "spec/std/isa/param/MTVEC_BASE_ALIGNMENT_VECTORED.yaml"
  ].freeze

  def test_enum_values_are_powers_of_two
    FILES.each do |rel|
      path = File.join(REPO_ROOT, rel)
      assert File.file?(path), "missing #{path}"
      doc = YAML.load_file(path)
      enum = doc.dig("schema", "enum")
      refute_nil enum, "#{rel}: missing schema.enum"
      enum.each do |v|
        assert v.is_a?(Integer) && v.positive?, "#{rel}: non-positive #{v.inspect}"
        assert_equal 0, v & (v - 1), "#{rel}: #{v} is not a power of 2"
      end
      refute_includes enum, 4095, "#{rel}: 4095 must not appear (not a power of 2)"
      assert_includes enum, 4096, "#{rel}: 4096 must be present"
    end
  end
end
