class AuthenticationPolicy < DefaultPolicy
  include ::WritePolicyMixin

  def index?
    # if the request is using psk auth it is authorized.
    psk? || !request.system&.cn
  end
  alias show? index?
end
