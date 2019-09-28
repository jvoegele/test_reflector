defmodule TestReflector.FieldTest do
  @moduledoc false
  use ExUnit.Case
  alias TestReflector.Field

  defmodule Module001Reflector do
    import Field
    require Field
    def_reflector_fld(:module_01, :my_function, :ok)
  end

  defmodule Module002Reflector do
    import Field
    require Field
    def_reflector_fld(:module_02, :my_function, :ok)
  end

  setup do
    %{data: "Some-Data", default: :ok}
  end

  describe "def_reflector_fld/3" do
    test "arity ZERO - my_function() - send reflected message" do
      Module001Reflector.my_function()
      assert_receive :my_function
    end

    test "arity ONE - my_function(arg1) - send reflected message" do
      Module001Reflector.my_function(:arg1)
      assert_receive {:my_function, :arg1}
    end

    test "arity TWO - my_function(arg1, arg2) - send reflected message" do
      Module001Reflector.my_function(:arg1, :arg2)
      assert_receive {:my_function, :arg1, :arg2}
    end

    test "arity THREE - my_function(arg1, arg2, arg3) - send reflected message" do
      Module001Reflector.my_function(:arg1, :arg2, :arg3)
      assert_receive {:my_function, :arg1, :arg2, :arg3}
    end

    test "def_reflector_fld - returns stash data", conn do
      Module001Reflector.stash_my_function(conn.data)
      assert conn.data == Module001Reflector.my_function()
    end

    test "def_reflector_fld - default", conn do
      assert conn.default == Module001Reflector.my_function()
    end

    test "scope. stash in  Module_01, read from Module_02.  Module_02 gets default ", conn do
      Module001Reflector.stash_my_function(conn.data)
      assert conn.default == Module002Reflector.my_function()
    end
  end
end
