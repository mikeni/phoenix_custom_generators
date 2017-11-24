defmodule <%= inspect context.module %>Test do
  use <%= inspect context.base_module %>.DataCase

  alias <%= inspect context.module %>
  <%= if schema.ex_machina_module do %>alias <%= schema.ex_machina_module %><% end %>
end
