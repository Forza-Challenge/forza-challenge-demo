defmodule FCDemo.DataSource do
  @moduledoc """
  Helpers for processing data from different sources
  """

  def validate_cast(data, types) when is_map(types) do
    all_fields = Map.keys(types)

    do_validate_cast(data, types, all_fields, all_fields)
  end

  def validate_cast(data, types, [{:optional, optional_fields}]) when is_list(optional_fields) do
    all_fields = Map.keys(types)
    required_fields = all_fields -- optional_fields

    do_validate_cast(data, types, all_fields, required_fields)
  end

  def validate_cast(data, types, [{:required, required_fields}]) when is_list(required_fields) do
    all_fields = Map.keys(types)

    do_validate_cast(data, types, all_fields, required_fields)
  end

  defp do_validate_cast(data, types, all_fields, required_fields)
       when is_map(data) and is_map(types) and is_list(all_fields) and is_list(required_fields) do
    {%{}, types}
    |> Ecto.Changeset.cast(data, all_fields)
    |> Ecto.Changeset.validate_required(required_fields)
    |> case do
      %{valid?: true, changes: changes} -> {:ok, changes}
      %{valid?: false, errors: errors} -> {:error, errors}
    end
  end
end
