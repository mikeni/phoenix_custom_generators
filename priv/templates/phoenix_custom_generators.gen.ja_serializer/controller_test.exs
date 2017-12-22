defmodule <%= module %>ControllerTest do
  use <%= base %>.ConnCase

  alias <%= module %>
  @valid_attrs %{<%= for {k, v} <- params do %>
    "<%= JaSerializer.Formatter.Utils.format_key(k) %>" => <%= inspect v %>,<% end %>
  }

  @invalid_attrs %{<%= for {k, v} <- params do %>
    "<%= JaSerializer.Formatter.Utils.format_key(k) %>" => nil,<% end %>
  }

  defp dasherize_keys(attrs) do
    Enum.map(attrs, fn {k, v} -> {JaSerializer.Formatter.Utils.format_key(k), v} end)
    |> Enum.into(%{})
  end

  <%= if Enum.count(refs) != 0 do %>
  defp relationships do <%= for ref <- refs do %>
    <%= ref %> = <%= if ex_machina_module do %><%= ex_machina_module %>.insert(:<%= ref %>)<% else %>Repo.insert!(%<%= base %>.<%= Phoenix.Naming.camelize(ref) %>{})<% end %><% end %>

    %{<%= for ref <- refs do %>
      "<%= ref %>" => %{
        "data" => %{
          "type" => "<%= JaSerializer.Formatter.Utils.format_key(ref) %>",
          "id" => <%= ref %>.id
        }
      },<% end %>
    }
  end<% end %><%= if Enum.count(refs) == 0 do %>
  defp relationships do
    %{}
  end<% end %>

  setup %{conn: conn} do
    conn = conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, <%= singular %>_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    <%= if ex_machina_module do %><%= singular %> = <%= ex_machina_module %>.insert(:<%= singular %>)
    <% else %><%= singular %> = Repo.insert! %<%= alias %>{}<% end %>
    conn = get conn, <%= singular %>_path(conn, :show, <%= singular %>)
    data =  json_response(conn, 200)["data"]
    assert data["id"] == "#{<%= singular %>.id}"
    assert data["type"] == "<%= JaSerializer.Formatter.Utils.format_key(singular) %>"
    <%= for {k, _} <- non_refs do %>assert data["attributes"]["<%= JaSerializer.Formatter.Utils.format_key(k) %>"] == <%= singular %>.<%= k %>
    <% end %><%= for {k, _} <- refs do %>assert data["relationships"]["<%= JaSerializer.Formatter.Utils.format_key(k) %>"]["data"]["id"] == Integer.to_string <%= singular %>.<%= k %>
    <% end %>
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, <%= singular %>_path(conn, :show, <%= inspect sample_id %>)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, <%= singular %>_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= JaSerializer.Formatter.Utils.format_key(singular) %>",
        "attributes" => dasherize_keys(@valid_attrs),
        "relationships" => relationships()
      }
    }
    assert json_response(conn, 201)["data"]["id"]
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, <%= singular %>_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= JaSerializer.Formatter.Utils.format_key(singular) %>",
        "attributes" => dasherize_keys(@invalid_attrs),
        "relationships" => relationships()
      }
    }
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    <%= if ex_machina_module do %><%= singular %> = <%= ex_machina_module %>.insert(:<%= singular %>)
    <% else %><%= singular %> = Repo.insert! %<%= alias %>{}<% end %>
    conn = put conn, <%= singular %>_path(conn, :update, <%= singular %>), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= JaSerializer.Formatter.Utils.format_key(singular) %>",
        "id" => <%= singular %>.id,
        "attributes" => @valid_attrs,
        "relationships" => relationships
      }
    }
    assert json_response(conn, 200)["data"]["id"]
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    <%= if ex_machina_module do %><%= singular %> = <%= ex_machina_module %>.insert(:<%= singular %>)
    <% else %><%= singular %> = Repo.insert! %<%= alias %>{}<% end %>
    conn = put conn, <%= singular %>_path(conn, :update, <%= singular %>), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= JaSerializer.Formatter.Utils.format_key(singular) %>",
        "id" => <%= singular %>.id,
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    <%= if ex_machina_module do %><%= singular %> = <%= ex_machina_module %>.insert(:<%= singular %>)
    <% else %><%= singular %> = Repo.insert! %<%= alias %>{}<% end %>
    conn = delete conn, <%= singular %>_path(conn, :delete, <%= singular %>)
    assert response(conn, 204)
    refute Repo.get(<%= alias %>, <%= singular %>.id)
  end
end
