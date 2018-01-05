defmodule <%= module %>Test do
  use <%= base %>.ModelCase

  alias <%= module %>

  @valid_attrs %{<%= for {k, v} <- params do %>
    <%= k %>: <%= inspect v %>,<% end %><%= for {_, k, _, _} <- assocs do %>
    <%= k %>: 42,<% end %>
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = <%= alias %>.changeset(%<%= alias %>{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = <%= alias %>.changeset(%<%= alias %>{}, @invalid_attrs)
    refute changeset.valid?
  end
end
