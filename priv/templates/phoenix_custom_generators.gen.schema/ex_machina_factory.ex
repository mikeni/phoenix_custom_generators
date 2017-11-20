  
  def <%= schema.singular %>_factory do
    %<%= inspect schema.module %>{<%= for {singular, k, mod, plural} <- schema.assocs do %>
      <%= singular %>: build(<%= inspect singular %>),<% end %><%= for {k, v} <- schema.params.create do %>
      <%= k %>: <%= inspect v %>,<% end %>
    }
  end
