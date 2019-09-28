# TestReflector

## Installation

Soon (but not yet) it will be [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `test_reflector` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:test_reflector, "~> 0.1.1"}
  ]
end
```

## Pattern Name
TestReflector

## Problem
  In a TestCase how do we: 
  1. assert that dependent module-functions were called by the Code-Under-Test?
  1. assert that the correct arguments were passed to the dependent module-functions?
  1. stub out return data that the dependent module-function should return?

## Context
  We are writing Micro-Tests, aka Unit-Tests.
  https://www.artima.com/weblogs/viewpost.jsp?thread=126923
  Classic blog post by Mike Feathers and what makes unit different from Integration testing.   [A Set of Unit Testing Rules](https://www.artima.com/weblogs/viewpost.jsp?thread=126923)
  I suggest that in Elixir we can call this `Module testing`.  And limit the test to one module at a time.

## Solution 
  Inject into the Code-Under-Test a **Reflector** with the same interface as the real depedency.
  *  A **Reflector** is a kind of *Test Double* that has the same interface as  the dependency (sometimes using a @behaviour)
  *  The interface function is stubbed by a default return value, and can be stashed with a customreturn value per test
  *  The **Reflector** sends a message back to the test-process when the interface function is called.
  *  The message sent back to the test-process contains the name of the called function and the arguments 

## Limitations
  * Reflectors are limited for when the test and target code are in the same process.  This is actually good because it helps us keep the tests smaller and more focused.

---

## Example using Reflector in a test 


  See the real usage in: `TestReflector.DemoTest`

  ```
  @deps %{ needed: DependentReflector }

  test "some test pseudo code for demo purposes" do
    # Given
    resource = build(:resource)
    DependentReflector.stash_get({:ok, 42})
    # When
    result = TargetCode.a_function_that_calls_dependent_get(@params, @deps)
    # Then
    assert {:ok, asset} == result
    assert asset.resource_id == resource.id
    assert_receive {:get, _}
  end
  ```

  ## Defining the ResourceReflector

   provide only semantically meaningful parts
  * the message reflected back depends on the arity
  *  **my_function()**  sends back **:name_of_function**
  *  **my_function(arg1)** sends back **{:name_of_function, arg_1}**
  *  **my_function(arg1, arg2)** sends back **{:name_of_function, arg1, arg2}**
  * the function return value is either 
    * the default defined in the macro call, or 
    * whatever _term_ was stashed for that scope and function name
  ```
  defmodule ResourceReflector do
    @behaviour Somewhere.ResourceBehaviour
    #         scope,     function,             default-result
    reflector(:resource, :all,                 [])
    reflector(:resource, :get,                 {:ok, %{}})
    reflector(:resource, :update,              {:ok, %{}})
    reflector(:resource, :create,              {:ok, %{}})
    reflector(:resource, :delete,              :ok)
  end
  ```


