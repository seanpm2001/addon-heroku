defmodule HerokuConnector.DnsimpleOauthView do
  use HerokuConnector.Web, :view

  def token(access_token), do: access_token.access_token
end