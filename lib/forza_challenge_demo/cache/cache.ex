defmodule FCDemo.Cache do
  @moduledoc """
  In memory storage implemented with con_cache
  """

  @name FCDemo.ConCache

  def put(key, value), do: ConCache.put(@name, key, value)

  def get(key), do: ConCache.get(@name, key)
end
