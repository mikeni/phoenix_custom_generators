defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ControllerTest do
  use <%= inspect context.web_module %>.ConnCase

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>
  <%= if schema.ex_machina_module do %>alias <%= schema.ex_machina_module %><% end %>

  @create_attrs %{<%= for {k, v} <- schema.params.create do %>
    <%= k %>: <%= inspect v %>,<% end %>
  }
  @update_attrs %{<%= for {k, v} <- schema.params.update do %>
    <%= k %>: <%= inspect v %>,<% end %>
  }
  @invalid_attrs %{<%= for {k, _} <- schema.params.create do %>
    <%= k %>: nil,<% end %>
  }

  <%= unless schema.ex_machina_module do %>def fixture(:<%= schema.singular %>) do
    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.create_<%= schema.singular %>(@create_attrs)
    <%= schema.singular %>
  end<% end %>

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all <%= schema.plural %>", %{conn: conn} do
      conn = get conn, <%= schema.route_helper %>_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create <%= schema.singular %>" do
    test "renders <%= schema.singular %> when data is valid", %{conn: conn} do
      attrs = @create_attrs
      <%= for {ref, key, _, _} <- schema.assocs do %><%= ref %> = <%= if schema.ex_machina_module do %><%= schema.ex_machina_module %>.insert(:<%= ref %>)
      <% else %>fixture(:<%= ref %>)
      <% end %>attrs = Map.merge(attrs, %{<%= key %>: <%= ref %>.id })
      <% end %>
      conn = post conn, <%= schema.route_helper %>_path(conn, :create), <%= schema.singular %>: attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, <%= schema.route_helper %>_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id<%= for {key, val} <- schema.params.create_json do %>,
        "<%= key %>" => <%= inspect val %><% end %>}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, <%= schema.route_helper %>_path(conn, :create), <%= schema.singular %>: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update <%= schema.singular %>" do
    setup [:create_<%= schema.singular %>]

    test "renders <%= schema.singular %> when data is valid", %{conn: conn, <%= schema.singular %>: %<%= inspect schema.alias %>{id: id} = <%= schema.singular %>} do
      conn = put conn, <%= schema.route_helper %>_path(conn, :update, <%= schema.singular %>), <%= schema.singular %>: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, <%= schema.route_helper %>_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id<%= for {key, val} <- schema.params.update_json do %>,
        "<%= key %>" => <%= inspect val %><% end %>}
    end

    test "renders errors when data is invalid", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn = put conn, <%= schema.route_helper %>_path(conn, :update, <%= schema.singular %>), <%= schema.singular %>: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete <%= schema.singular %>" do
    setup [:create_<%= schema.singular %>]

    test "deletes chosen <%= schema.singular %>", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn = delete conn, <%= schema.route_helper %>_path(conn, :delete, <%= schema.singular %>)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, <%= schema.route_helper %>_path(conn, :show, <%= schema.singular %>)
      end
    end
  end

  defp create_<%= schema.singular %>(_) do
    <%= if schema.ex_machina_module do %><%= schema.singular %> = <%= schema.ex_machina_module %>.insert(:<%= schema.singular %>)
    <% else %><%= schema.singular %> = fixture(:<%= schema.singular %>)<% end %>
    {:ok, <%= schema.singular %>: <%= schema.singular %>}
  end
end
