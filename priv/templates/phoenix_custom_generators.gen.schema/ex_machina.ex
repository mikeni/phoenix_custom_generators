defmodule RecruiterMark.ExMachinaFactory do
  
  <%= if schema.generate? do %>use ExMachina.Ecto, repo: RecruiterMark.Repo
  <% else %>use ExMachina<% end %>

  

end