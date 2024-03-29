defmodule TestReflector.DemoTest do
  @moduledoc false
  use ExUnit.Case

  # define MyRepoBehaviour ----------------------------------------------------------------------
  defmodule MyRepoBehaviour do
    @moduledoc false
    @callback some_data_i_need() :: {:ok, binary} | {:error, binary}
  end

  # define RealMyRepoModule ----------------------------------------------------------------------
  defmodule RealMyRepoModule do
    @behaviour MyRepoBehaviour

    @impl MyRepoBehaviour
    def some_data_i_need() do
      # does slow or side-effect stuff here in the real world
      # so we don't what this to run in our micro-tests (aka unit-tests)
      # the Reflector will do this instead.
      {:ok, "Something amazing from a dependent source"}
    end
  end

  defmodule TargetCode do
    def something(input_number, dep \\ RealMyRepoModule) do
      {:ok, string_from_dependency} = dep.some_data_i_need()
      combined_result = string_from_dependency <> Integer.to_string(input_number)
      {:ok, combined_result}
    end
  end

  # define MyRepoReflector ----------------------------------------------------------------------
  defmodule MyRepoReflector do
    import TestReflector
    require TestReflector

    @behaviour MyRepoBehaviour
    #                 scope,      function,           default-result
    reflect(:something, :some_data_i_need, {:ok, "nothing"})
    # . . .
  end

  test "using the Reflector to remove slow or side-effect dependency" do
    # Given
    stubbed_data = "Something just for the test"
    MyRepoReflector.stash_some_data_i_need({:ok, stubbed_data})
    # When
    result = TargetCode.something(234, MyRepoReflector)
    # Then
    assert {:ok, "Something just for the test234"} == result
    assert_receive :some_data_i_need
  end

  test "calling the real code by default" do
    # Given
    stubbed_data = "Something just for the test"
    MyRepoReflector.stash_some_data_i_need({:ok, stubbed_data})
    # When
    result = TargetCode.something(234)
    # Then
    assert {:ok, "Something amazing from a dependent source234"} == result
    refute_receive :some_data_i_need
  end
end
