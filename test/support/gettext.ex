defmodule Doggo.Gettext do
  @moduledoc false
  use Gettext.Backend, otp_app: :doggo, priv: "test/support/gettext"
end
