defmodule MousepartyWeb.PageLive do
  use MousepartyWeb, :live_view
  alias Mouseparty.Accounts
  alias MousepartyWeb.Presence
  @topic "documents:mainpage"

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    MousepartyWeb.Endpoint.subscribe(@topic)
    current_user = Accounts.get_user_by_session_token(token)
    send(self(), :track_presence_after_join)

    {:ok,
     assign(
       socket,
       current_user: current_user,
       users: []
     )}
  end

  def handle_info(
        :track_presence_after_join,
        %{assigns: %{current_user: current_user}} = socket
      ) do
    {:ok, _} =
      Presence.track(
        # pid
        self(),
        # topic
        @topic,
        # key
        socket.id,
        %{
          email: current_user.email,
          id: current_user.id,
          coords: %{"x" => 0, "y" => 0, "k" => 1}
        }
      )

    {:noreply, socket}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{current_user: %{email: email}}} = socket
      ) do
    users =
      Presence.list(@topic)
      |> Enum.map(fn {_phx_user_id, data} ->
        data[:metas]
        |> List.first()
      end)
      |> Enum.filter(&(&1.email != email))

    {:noreply, assign(socket, users: users)}
  end

  @impl true
  def handle_event("mouse_move", value, %{assigns: %{current_user: current_user}} = socket) do
    Presence.update(
      # pid
      self(),
      # topic
      @topic,
      # key
      socket.id,
      %{coords: value, id: current_user.id, email: current_user.email}
    )

    {:noreply, socket}
  end
end
