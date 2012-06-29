Puppet::Type.newtype(:github_api_request) do
  @doc = "Type to make requests via the Github API"

  ensurable

  newparam :params do
    desc "Hash that represents the parameters to be sent to the url. This will be converted to JSON before sending."
  end

  newparam :token do
    desc "Your OAuth access token. See http://developer.github.com/v3/oauth/ for more information on obtaining an access token."
  end

  newparam :url do
    desc "The URL to request. This must contain only the path without the host (automatically uses api.github.com)."

    isnamevar
  end

end
