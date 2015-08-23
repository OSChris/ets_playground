defmodule EtsPlaygroundTest do
  use ExUnit.Case

  setup do
    cars = :ets.new(:cars, [:bag, :named_table])
    :cars |> :ets.insert({"328i", "BMW", "White", 2014})
    :cars |> :ets.insert({"335i", "BMW", "Blue", 2012})
    :cars |> :ets.insert({"528i", "BMW", "Black", 2015})
    :ok
  end

  test "creating a table and getting its info" do
    info = :ets.info(:cars)
    IO.inspect info
    assert info[:type] == :bag
  end

  test "inserting and retreiving data" do
    [{_model, make, _color, _year}|_tail] = :ets.lookup(:cars, "328i")
    assert make == "BMW"
  end

  test "traversing the table sequentially" do
    first  = :ets.first(:cars)
    second = :ets.next(:cars, first)
    third  = :ets.next(:cars, second)
    assert third == "528i"
    assert :"$end_of_table" == :ets.next(:cars, third)
  end

  test "querying the table for data that matches a pattern" do
    query = {:_, :_, :_, 2012}
    cars_from_2012 = :ets.match_object(:cars, query)
    [{model, _, _, _}|_tail] = cars_from_2012
    assert model == "335i"
  end

  test "querying using match specs" do
    query = [
      {
        {:_, :_, :_, :"$1"},
        [{:andalso,
          {:'>=', :"$1", 2011},
          {:'=<', :"$1", 2014}
        }],
        [:"$_"]
      }
    ]
    selected_cars = :ets.select(:cars, query)
    IO.inspect selected_cars
    assert Enum.count(selected_cars) == 2
  end
end
