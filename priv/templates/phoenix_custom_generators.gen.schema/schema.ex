defmodule <%= inspect schema.module %> do
  use Ecto.Schema
  import Ecto.Changeset
  alias <%= inspect schema.module %>

<%= if schema.binary_id do %>
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id<% end %>
  schema <%= inspect schema.table %> do
<%= for {k, v} <- schema.types do %>    field <%= inspect k %>, <%= inspect v %><%= schema.defaults[k] %>
<% end %><%= for {name, k, mod, _} <- schema.assocs do %>    field <%= inspect k %>, <%= if schema.binary_id do %>:binary_id<% else %>:id<% end %>
    # belongs_to <%= name %>, <%= mod %>
<% end %>
    timestamps()
  end

  @doc false
  def changeset(%<%= inspect schema.alias %>{} = <%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> cast(attrs, [
      <%= for {k, _} <- schema.attrs do %><%= inspect k%>,
      <% end %>
    ])
    |> validate_required([
      <%= for {k, _} <- schema.attrs do %><%= inspect k%>,
      <% end %>
    ])
<%= for k <- schema.uniques do %>    |> unique_constraint(<%= inspect k %>)
<% end %>  end
end
