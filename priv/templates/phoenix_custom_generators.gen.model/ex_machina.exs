  def <%= singular %>_factory do
    %<%= module %>{<%= for {k, v} <- params_factory_girl do %>
      <%= k %>: <%= v %>,<% end %>
    }
  end