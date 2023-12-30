defmodule Doggo.Gettext do
  @moduledoc false
  use Gettext, otp_app: :doggo, priv: "test/support/gettext"
end
