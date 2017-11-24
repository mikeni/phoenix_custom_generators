
  describe "<%= schema.plural %>" do
    alias <%= inspect schema.module %>

    @valid_attrs %{<%= for {k, v} <- schema.params.create do %>
      <%= k %>: <%= inspect v %>,<% end %>
    }
    @update_attrs %{<%= for {k, v} <- schema.params.update do %>
      <%= k %>: <%= inspect v %>,<% end %>
    }
    @invalid_attrs %{<%= for {k, _} <- schema.params.create do %>
      <%= k %>: nil,<% end %>
    }

<%= unless schema.ex_machina_module do %>    def <%= schema.singular %>_fixture(attrs \\ %{}) do
      {:ok, <%= schema.singular %>} =
        attrs
        |> Enum.into(@valid_attrs)
        |> <%= inspect context.alias %>.create_<%= schema.singular %>()

      <%= schema.singular %>
    end
<% end %>    test "list_<%= schema.plural %>/0 returns all <%= schema.plural %>" do
<%= if schema.ex_machina_module do %>      <%= schema.singular %> = <%= schema.ex_machina_module %>.insert(:<%= schema.singular %>)
<% else %>      <%= schema.singular %> = <%= schema.singular %>_fixture()
<% end %>      assert <%= inspect context.alias %>.list_<%= schema.plural %>() == [<%= schema.singular %>]
    end

    test "get_<%= schema.singular %>!/1 returns the <%= schema.singular %> with given id" do
<%= if schema.ex_machina_module do %>      <%= schema.singular %> = <%= schema.ex_machina_module %>.insert(:<%= schema.singular %>)
<% else %>      <%= schema.singular %> = <%= schema.singular %>_fixture()
<% end %>      assert <%= inspect context.alias %>.get_<%= schema.singular %>!(<%= schema.singular %>.id) == <%= schema.singular %>
    end

    test "create_<%= schema.singular %>/1 with valid data creates a <%= schema.singular %>" do
      assert {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} = <%= inspect context.alias %>.create_<%= schema.singular %>(@valid_attrs)<%= for {field, value} <- schema.params.create do %>
      assert <%= schema.singular %>.<%= field %> == <%= Mix.Phoenix.Schema.value(schema, field, value) %><% end %>
    end

    test "create_<%= schema.singular %>/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = <%= inspect context.alias %>.create_<%= schema.singular %>(@invalid_attrs)
    end

    test "update_<%= schema.singular %>/2 with valid data updates the <%= schema.singular %>" do
<%= if schema.ex_machina_module do %>      <%= schema.singular %> = <%= schema.ex_machina_module %>.insert(:<%= schema.singular %>)
<% else %>      <%= schema.singular %> = <%= schema.singular %>_fixture()
<% end %>      assert {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>, @update_attrs)
      assert %<%= inspect schema.alias %>{} = <%= schema.singular %><%= for {field, value} <- schema.params.update do %>
      assert <%= schema.singular %>.<%= field %> == <%= Mix.Phoenix.Schema.value(schema, field, value) %><% end %>
    end

    test "update_<%= schema.singular %>/2 with invalid data returns error changeset" do
<%= if schema.ex_machina_module do %>      <%= schema.singular %> = <%= schema.ex_machina_module %>.insert(:<%= schema.singular %>)
<% else %>      <%= schema.singular %> = <%= schema.singular %>_fixture()
<% end %>      assert {:error, %Ecto.Changeset{}} = <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>, @invalid_attrs)
      assert <%= schema.singular %> == <%= inspect context.alias %>.get_<%= schema.singular %>!(<%= schema.singular %>.id)
    end

    test "delete_<%= schema.singular %>/1 deletes the <%= schema.singular %>" do
<%= if schema.ex_machina_module do %>      <%= schema.singular %> = <%= schema.ex_machina_module %>.insert(:<%= schema.singular %>)
<% else %>      <%= schema.singular %> = <%= schema.singular %>_fixture()
<% end %>      assert {:ok, %<%= inspect schema.alias %>{}} = <%= inspect context.alias %>.delete_<%= schema.singular %>(<%= schema.singular %>)
      assert_raise Ecto.NoResultsError, fn -> <%= inspect context.alias %>.get_<%= schema.singular %>!(<%= schema.singular %>.id) end
    end

    test "change_<%= schema.singular %>/1 returns a <%= schema.singular %> changeset" do
<%= if schema.ex_machina_module do %>      <%= schema.singular %> = <%= schema.ex_machina_module %>.insert(:<%= schema.singular %>)
<% else %>      <%= schema.singular %> = <%= schema.singular %>_fixture()
<% end %>      assert %Ecto.Changeset{} = <%= inspect context.alias %>.change_<%= schema.singular %>(<%= schema.singular %>)
    end
  end
