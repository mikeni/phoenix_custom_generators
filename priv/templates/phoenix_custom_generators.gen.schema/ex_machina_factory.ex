  
  def <%= schema.singular %>_factory do
    %<%= inspect schema.module %>{<%= for {k, v} <- schema.params.create do %>
      <%= k %>: <%= inspect v %>,<% end %>
    }
  end
