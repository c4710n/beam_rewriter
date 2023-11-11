defmodule BeamRewriter.Rule do
  @enforce_keys [:action]

  defstruct action: nil, args: []

  @type t :: %__MODULE__{
          action: [:substitute | :delete],
          args: list()
        }
end
