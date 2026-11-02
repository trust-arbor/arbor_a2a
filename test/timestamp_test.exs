defmodule Arbor.A2A.TimestampTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.Timestamp

  @tag :unknown_offset
  test "unknown local zero offset still identifies the UTC instant" do
    assert {:ok, 1} = Timestamp.parse("1970-01-01T00:00:00.000000001-00:00")
  end

  test "offset normalization retains all nine fractional digits" do
    assert {:ok, 1} = Timestamp.parse("1970-01-01T00:00:00.000000001Z")
    assert {:ok, 1} = Timestamp.parse("1970-01-01T01:00:00.000000001+01:00")
    assert {:ok, 123_456_789} = Timestamp.parse("1970-01-01T00:00:00.123456789Z")
    assert {:ok, -1} = Timestamp.parse("1969-12-31T23:59:59.999999999Z")
    assert {:ok, 0} = Timestamp.parse("1970-01-01t00:00:00z")
  end

  for invalid <- [
        nil,
        0,
        "",
        "2026-02-30T00:00:00Z",
        "2026-01-01T00:00:00.1234567890Z",
        "2026-01-01",
        "0000-01-01T00:00:00Z",
        "2026-01-01T00:00:00.Z"
      ] do
    test "rejects invalid ProtoJSON timestamp #{inspect(invalid)}" do
      assert {:error, :invalid_timestamp} = Timestamp.parse(unquote(invalid))
    end
  end
end
