defmodule HerokuConnector.Dnsimple do
  # OAuth

  def authorize_url(client, client_id, options) do
    Dnsimple.OauthService.authorize_url(client, client_id, state: options[:state])
  end

  def exchange_authorization_for_token(client, attributes) do
    oauth_service.exchange_authorization_for_token(client, attributes)
  end

  # Identity

  def whoami(client) do
    identity_service.whoami(client)
  end

  # Domains

  def domains(account) do
    case domain_service.domains(client(account), account.id) do
      {:ok, response} -> response.data
      {:error, error} ->
        IO.inspect(error)
        raise "Failed to retrieve domains: #{inspect error}"
    end
  end

  def domain(account, id) do
    case domain_service.domain(client(account), account.id, id) do
      {:ok, response} -> response.data
      {:error, error} ->
        IO.inspect(error)
        raise "Failed to retrieve domain: #{inspect error}"
    end
  end

  # Domain Services

  def applied_services(account, domain_name) do
    case domain_service_service.applied_services(client(account), account.id, domain_name) do
      {:ok, response} -> response.data
      {:error, error} ->
        IO.inspect(error)
        raise "Failed to retrieve domain services: #{inspect error}"
    end
  end

  def apply_service(account, domain_name, service_id) do
    case domain_service_service.apply_service(client(account), account.id, domain_name, service_id) do
      {:ok, _response} -> service_id
      {:error, error} ->
        IO.inspect(error)
        raise "Failed to apply service: #{inspect error}"
    end
  end

  def unapply_service(account, domain_name, service_id) do
    case domain_service_service.unapply_service(client(account), account.id, domain_name, service_id) do
      {:ok, _response} -> service_id
      {:error, error} ->
        IO.inspect(error)
        raise "Failed to unapply service: #{inspect error}"
    end
  end

  # Records

  def create_records(account, zone_name, records) do
    c = client(account)
    zs = zone_service
    Enum.map(records, &(zs.create_record(c, account.id, zone_name, &1)))
  end

  def delete_records(account, zone_name, record_ids) do
    c = client(account)
    zs = zone_service
    Enum.map(record_ids, &(zs.delete_record(c, account.id, zone_name, &1)))
  end

  # Client for account

  def client(account) do
    %Dnsimple.Client{access_token: account.dnsimple_access_token}
  end

  # Service modules

  defp oauth_service do
    Application.get_env(:heroku_connector, :dnsimple_oauth_service, Dnsimple.OauthService)
  end

  defp identity_service do
    Application.get_env(:heroku_connector, :dnsimple_identity_service, Dnsimple.IdentityService)
  end

  defp domain_service do
    Application.get_env(:heroku_connector, :dnsimple_domains_service, Dnsimple.DomainsService)
  end

  defp domain_service_service do
    Application.get_env(:heroku_connector, :dnsimple_domain_services_service, Dnsimple.DomainServicesService)
  end

  defp zone_service do
    Application.get_env(:heroku_connector, :dnsimple_zones_service, Dnsimple.ZonesService)
  end
end
