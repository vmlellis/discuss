defmodule DiscussWeb.AuthController do
  use DiscussWeb, :controller
  plug Ueberauth

  alias Discuss.Accounts

  def callback(conn, _params) do
    # IO.puts "++++++++"
    # IO.inspect(conn.assigns)
    # IO.puts "++++++++"
    # IO.inspect(params)
    # IO.puts "++++++++"

    %{assigns: %{ueberauth_auth: auth}} = conn
    # IO.puts "++++++++"
    # IO.inspect(auth)
    # IO.puts "++++++++"
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email,
      provider: Atom.to_string(auth.provider)
    }
    # IO.inspect(user_params)
    # IO.puts "++++++++"

    conn |> signin(user_params)
  end

  defp signin(conn, user_params) do
    case Accounts.create_or_update_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, reason} ->
        IO.puts "++++++++"
        IO.inspect(reason)
        IO.puts "++++++++"
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: Routes.topic_path(conn, :index))
    end
  end
end
