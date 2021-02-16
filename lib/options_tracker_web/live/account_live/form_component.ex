defmodule OptionsTrackerWeb.AccountLive.FormComponent do
  use OptionsTrackerWeb, :live_component

  alias OptionsTracker.Accounts
  import OptionsTrackerWeb.AccountLive.Helpers

  @impl true
  @spec update(%{account: Account.t()}, Phoenix.LiveView.Socket.t()) ::
          {:ok, Phoenix.LiveView.Socket.t()}
  def update(%{account: account} = assigns, socket) do
    changeset = Accounts.change_account(account)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  @spec handle_event(String.t(), %{required(String.t()) => map}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("validate", %{"account" => account_params}, socket) do
    changeset =
      socket.assigns.account
      |> Accounts.change_account(account_params |> compact() |> defaults_for_type())
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    save_account(socket, socket.assigns.action, account_params)
  end

  defp save_account(socket, :edit, account_params) do
    case Accounts.update_account(socket.assigns.account, account_params) do
      {:ok, _account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_account(socket, :new, account_params) do
    case Accounts.create_account(account_params) do
      {:ok, _account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  for {t, value} <- Accounts.list_account_types() do
    defp defaults_for_type(%{"type" => v} = params) when v in [unquote(to_string(value)), unquote(value), unquote(to_string(t)), unquote(t)] do
      Accounts.defaults_for_type(unquote(t))
      |> stringify_keys()
      |> Map.merge(params)
    end
  end

  defp defaults_for_type(params), do: params
end
