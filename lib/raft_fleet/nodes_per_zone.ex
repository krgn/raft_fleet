use Croma
alias Croma.TypeGen, as: TG

defmodule RaftFleet.NodesPerZone do
  alias RaftFleet.{Hash, ZoneId}
  use Croma.SubtypeOfMap, key_module: ZoneId, value_module: TG.list_of(Croma.Atom)

  defun lrw_members(nodes_per_zone :: t,
                    task_id        :: atom | any, # This is basically a group name (atom) but any ID that can be assigned to node(s) is acceptable
                    n_to_take      :: pos_integer) :: [node] do
    Enum.flat_map(nodes_per_zone, fn {_z, ns} ->
      Enum.map(ns, fn n -> {Hash.calc({n, task_id}), n} end)
      |> Enum.sort()
      |> Enum.map_reduce(0, fn({hash, node}, index) -> {{index, hash, node}, index + 1} end)
      |> elem(0)
    end)
    |> Enum.sort()
    |> Enum.take(n_to_take)
    |> Enum.map(fn {_i, _h, n} -> n end)
  end
end
