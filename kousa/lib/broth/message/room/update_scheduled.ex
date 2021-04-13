defmodule Broth.Message.Room.UpdateScheduled do
  use Broth.Message.Call,
    reply: __MODULE__,
    operation: "room:update_scheduled:reply"

  alias Beef.Repo

  @primary_key {:id, :binary_id, []}
  schema "scheduled_rooms" do
    field(:name, :string)
    field(:scheduledFor, :utc_datetime_usec)
    field(:description, :string, default: "")
  end

  import Broth.Message.Room.CreateScheduled, only: [validate_future: 1]

  def changeset(_, data) when
    not is_map_key(data, "id") or
    is_nil(:erlang.map_get("id", data)) do

    %__MODULE__{}
    |> change
    |> add_error(:id, "can't be blank")
  end
  def changeset(_, data) do
    case Repo.get(__MODULE__, data["id"]) do
      nil ->
        %__MODULE__{}
        |> change
        |> add_error(:id, "room not found")
      room ->
        room
        |> cast(data, [:name, :scheduledFor, :description])
        |> validate_required([:name, :scheduledFor])
        |> validate_future
    end
  end

end
