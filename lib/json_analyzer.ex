defmodule JsonAnalyzer do
  @moduledoc """
  Documentation for JsonAnalyzer.
  """

  @doc """
  Hello world.

  ## Examples

      iex> JsonAnalyzer.analyze(IHM.json)
      :ok
      #=> Result.json updated

  """
  def analyze(path) when is_binary(path) do
    result =
      File.read!(path)
      |> Poison.decode!()
      |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
      |> Enum.reduce(%{}, &invert_tuple(&2, &1))

    File.write!("Result.json", Poison.encode!(result, iodata: true, pretty: true))
  end

  defp invert_tuple(map, tuple) do
    new_key = elem(tuple, 1)
    new_val = elem(tuple, 0)

    Map.update(map, new_key, [new_val], fn val -> val ++ [new_val] end)
  end
end
