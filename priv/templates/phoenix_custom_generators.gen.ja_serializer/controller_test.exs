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

  def fixture(:<%= schema.singular %>) do
    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.create_<%= schema.singular %>(@create_attrs)
    <%= schema.singular %>
  end

  <%= if Enum.count(schema.assocs) != 0 do %>
  defp relationships do <%= for {ref, key, mod, _} <- schema.assocs do %>
    <%= ref %> = Repo.insert!(%<%= mod %>{})<% end %>

    %{<%= for {ref, key, _, _} <- schema.assocs do %>
      "<%= ref %>" => %{
        "data" => %{
          "type" => "<%= ref %>",
          "id" => <%= ref %>.id
        }
      },<% end %>
    }
  end<% end %><%= if Enum.count(schema.assocs) == 0 do %>
  defp relationships do
    %{}
  end<% end %>

  setup %{conn: conn} do
    conn = conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all <%= schema.plural %>", %{conn: conn} do
      conn = get conn, <%= schema.route_helper %>_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create <%= schema.singular %>" do
    test "renders <%= schema.singular %> when data is valid", %{conn: conn} do
      conn = post conn, <%= schema.route_helper %>_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "<%= JaSerializer.Formatter.Utils.format_key(schema.singular) %>",
          "attributes" => @create_attrs,
          "relationships" => relationships
        }
      }
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, <%= schema.route_helper %>_path(conn, :show, id)
      data = json_response(conn, 200)["data"]
      assert data["id"] == "#{id}"
      assert data["type"] == "<%= JaSerializer.Formatter.Utils.format_key(schema.singular) %>"
      <%= for {k, v} <- schema.params.create_json do %>assert data["attributes"]["<%= JaSerializer.Formatter.Utils.format_key(k) %>"] == <%= inspect v %>
      <% end %>
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, <%= schema.route_helper %>_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "<%= JaSerializer.Formatter.Utils.format_key(schema.singular) %>",
          "attributes" => @invalid_attrs,
          "relationships" => relationships
        }
      }
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update <%= schema.singular %>" do
    setup [:create_<%= schema.singular %>]

    test "renders <%= schema.singular %> when data is valid", %{conn: conn, <%= schema.singular %>: %<%= inspect schema.alias %>{id: id} = <%= schema.singular %>} do
      conn = put conn, <%= schema.route_helper %>_path(conn, :update, <%= schema.singular %>), %{
        "meta" => %{},
        "data" => %{
          "type" => "<%= JaSerializer.Formatter.Utils.format_key(schema.singular) %>",
          "id" => "#{<%= schema.singular %>.id}",
          "attributes" => @update_attrs,
          "relationships" => relationships
        }
      }
      data = json_response(conn, 200)["data"]
      assert data["id"] == "#{id}"
      assert data["type"] == "<%= JaSerializer.Formatter.Utils.format_key(schema.singular) %>"
      <%= for {k, v} <- schema.params.update_json do %>assert data["attributes"]["<%= JaSerializer.Formatter.Utils.format_key(k) %>"] == <%= inspect v %>
      <% end %>

      conn = get conn, <%= schema.route_helper %>_path(conn, :show, id)
      data = json_response(conn, 200)["data"]
      assert data["id"] == "#{id}"
      assert data["type"] == "<%= JaSerializer.Formatter.Utils.format_key(schema.singular) %>"
      <%= for {k, v} <- schema.params.update_json do %>assert data["attributes"]["<%= JaSerializer.Formatter.Utils.format_key(k) %>"] == <%= inspect v %>
      <% end %>
    end

    test "renders errors when data is invalid", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn = put conn, <%= schema.route_helper %>_path(conn, :update, <%= schema.singular %>), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= JaSerializer.Formatter.Utils.format_key(schema.singular) %>",
        "id" => "#{<%= schema.singular %>.id}",
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }
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
