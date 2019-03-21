defmodule JsonAnalyzer do
  @moduledoc """
  Documentation for JsonAnalyzer.
  """

  @doc """
  Counts the ocurrences of specific maps in a json file and outputs it to another file
  This can be used for select-one questions (radio buttons), slider questions and many
  other types of form questions

  Using this function is not advised for select-multiple questions (checkboxes) as it
  only checks which people marked all the same checkboxes

  ## Examples

      iex> JsonAnalyzer.map_ocurrence("IHM Personas.json", "Results.json")
      :ok
      #=> Results.json created/updated

  """
  def map_ocurrence(input_path, output_path) when is_binary(input_path) and is_binary(output_path) do
    result =
      File.read!(input_path)
      |> Poison.decode!()
      |> Enum.reduce(%{}, fn x, acc -> count_ocurrences(acc, x) end)
      |> Enum.reduce(%{}, &invert_tuple(&2, &1))

    File.write!(output_path, Poison.encode!(result, iodata: true, pretty: true))
  end

  @doc """
  Counts the ocurrences of any of a list's values for a json file's question in a json
  file and outputs it to another file

  This is used for select-multiple questions (checkboxes), which give results as lists
  of the selected answers

  ## Examples

      iex> JsonAnalyzer.list_element_ocurrence("IHM Usability.json", "Results.json")
      :ok
      #=> Results.json created/updated

  """
  def list_element_ocurrence(input_path, output_path) when is_binary(input_path) and is_binary(output_path) do
    result =
      File.read!(input_path)
      |> Poison.decode!()
      |> Enum.reduce([], fn x, acc -> acc ++ open_list(x) end)
      |> Enum.reduce(%{}, fn x, acc -> count_ocurrences(acc, x) end)
      |> Enum.reduce(%{}, &invert_tuple(&2, &1))

    IO.inspect(result)
    File.write!(output_path, Poison.encode!(result, iodata: true, pretty: true))
  end

  defp open_list(element) do
    Map.to_list(element)
    |> Enum.map(fn x -> Enum.map(elem(x, 1), fn y -> Enum.join(Tuple.to_list({elem(x, 0), y}), ": ") end) end)
    |> List.flatten()
  end

  defp count_ocurrences(accumulator, element) do
    Map.update(accumulator, element, 1, &(&1 + 1))
  end

  defp invert_tuple(map, tuple) do
    new_key = elem(tuple, 1)
    new_val = elem(tuple, 0)

    Map.update(map, new_key, [new_val], fn val -> val ++ [new_val] end)
  end
end
