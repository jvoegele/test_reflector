# TestReflector

## Installation

```elixir
def deps do
  [
    {:test_reflector, "~> 0.1.4"}
  ]
end
```

* [TestReflector on Hex](https://hex.pm/packages/test_reflector)

## Pattern Name
TestReflector

## Problem
  In an isolated Test how do we: 
  1. assert that dependent module-functions were called by the Subject-Under-Test?
  1. assert that the correct arguments were passed to the dependent module-functions?
  1. stub out return data that the dependent module-function should return?

## Context
  We are writing isolated, pure, fast-running Unit Tests.
  In Elixir we can think of this as `Module testing`.  Because we want to limit the test to one module.
  Classic blog post by *Mike Feathers* and what makes unit different from Integration testing.   
  [A Set of Unit Testing Rules](https://www.artima.com/weblogs/viewpost.jsp?thread=126923)

  ##### A test is not a unit test if:

  1.  It talks to the database
  2.  It communicates across the network
  3.  It touches the file system
  4. It can't run at the same time as any of your other unit tests
  5. You have to do special things to your environment (such as editing config files) to run it.

In Elixir there are two more Rules:

  6. It can't read the System Time (subset of rule 5 above, but often forgotten)
  7. It cannot involve the erlang Scheduler.  No multiple processes.


## Solution 
  Inject into the Code-Under-Test a **Reflector** with the same interface as the real depedency.
  *  A **Reflector** is a kind of *Test Double* that has the same interface as the dependency (sometimes using a @behaviour)
  *  The interface function is stubbed by a default return value, and can be stashed with a customreturn value per test
  *  The **Reflector** sends a message back to the test-process when the interface function is called.
  *  The message sent back to the test-process contains the name of the called function and the arguments 
  *  Do not pass the Reflector more than one Module deep. 

## Limitations
  * Reflectors are limited for when the test and Subject-Under-Test are IN THE SAME PROCESS. 

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
    #       scope,     function,             default-result
    reflect(:resource, :all,                 [])
    reflect(:resource, :get,                 {:ok, %{}})
    reflect(:resource, :update,              {:ok, %{}})
    reflect(:resource, :create,              {:ok, %{}})
    reflect(:resource, :delete,              :ok)
  end
  ```


## Discussion

### Why not use techniques and tools like [MOX](https://github.com/plataformatec/mox) ?

See the **Mocks as locals** section in [Mocks and explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/ )

"Although we have used the application configuration for solving the external API issue, sometimes it is easier to just pass the dependency as argument. Imagine this example in Elixir where some function may perform heavy work which you want to isolate in tests:"  -- José Valim

José seems to say that Mox is good for large external interfaces.
And points to **Mocks as Locals** as a way to do testing for simpler smaller cases.  These simpler cases are Unit tests.




