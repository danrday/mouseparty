defmodule MousepartyWeb.PageLive do
  use MousepartyWeb, :live_view
  alias Mouseparty.Accounts
  alias MousepartyWeb.Presence
  @topic "documents:mainpage"

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    MousepartyWeb.Endpoint.subscribe(@topic)
    current_user = Accounts.get_user_by_session_token(token)

    {:ok, _} =
      Presence.track(
        self(),
        @topic,
        socket.id,
        %{
          email: current_user.email,
          id: current_user.id
        }
      )

    {:ok,
     assign(
       socket,
       query: "",
       results: %{},
       user_id: current_user.id,
       current_user: current_user,
       coords: %{},
       users: []
     )}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        socket
      ) do
    users =
      Presence.list(@topic)
      |> Enum.map(fn {_user_id, data} -> data[:metas] |> List.first() end)

    IO.inspect(Presence.list(@topic))

    {:noreply, assign(socket, users: users)}
  end

  @impl true
  def handle_event("mouse_move", value, socket) do
    IO.inspect(value)
    # IO.inspect(socket.assigns.current_user.email)

    MousepartyWeb.Endpoint.broadcast_from(self(), @topic, "user_coordinates", %{
      coords: value,
      user_id: socket.assigns.current_user.id
    })

    {:noreply, socket}
  end

  def handle_info(%{event: "user_coordinates", payload: state}, socket) do
    coords = socket.assigns.coords

    user_coords = Map.put(coords, state.user_id, state.coords)

    IO.inspect(user_coords)

    {:noreply, assign(socket, coords: user_coords)}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not MousepartyWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
