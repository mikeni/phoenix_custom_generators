defmodule <%= inspect schema.repo %>.Migrations.Create<%= Macro.camelize(schema.table) %> do
  use Ecto.Migration


  # Remember to set the add options for each field.
  # ex: primary_key, default, null, size, precision, scale.
  # Also remember to set the value for on_delete and on_update references options 
  # ex: :nothing, :delete_all, :nilify_all, :restrict
  def change do
    create table(:<%= schema.table %><%= if schema.binary_id do %>, primary_key: false<% end %>) do
<%= if schema.binary_id do %>      add :id, :binary_id, primary_key: true
<% end %><%= for {k, v} <- schema.attrs do %>      add <%= inspect k %>, <%= inspect v %><%= schema.migration_defaults[k] %>
<% end %><%= for {_, i, _, s} <- schema.assocs do %>      add <%= if(String.ends_with?(inspect(i), "_id"), do: inspect(i), else: inspect(i) <> "_id") %>, references(<%= inspect(s) %>, on_delete: :nothing<%= if schema.binary_id do %>, type: :binary_id<% end %>)
<% end %>
      timestamps()
    end
<%= for index <- schema.indexes do %>
    <%= index %><% end %>
  end
end
