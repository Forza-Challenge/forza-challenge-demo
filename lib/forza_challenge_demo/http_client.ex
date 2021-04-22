defmodule FCDemo.HttpClient do
  @moduledoc """
  HTTP request module - finch
  """

  @finch_name FCDemo.Finch

  def get_json(url, headers \\ []) when is_binary(url) and is_list(headers) do
    req_headers = [{"Accept", "application/json"} | headers]

    Finch.build(:get, url, req_headers)
    |> Finch.request(@finch_name)
    |> process_json_resp()
  end

  # Helpers
  defp process_json_resp({:error, error}), do: {:error, {:http_client, error}}

  defp process_json_resp({:ok, %{body: body, headers: _headers, status: status}}) when status in 200..299 do
    case Jason.decode(body) do
      {:ok, res} -> {:ok, res}
      {:error, error} -> {:error, {:http_client, error}}
    end
  end
end
