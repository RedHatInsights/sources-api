class ApplicationPolicy < DefaultPolicy
  include ::WritePolicyMixin

  def index?
    !request.system&.cn
  end
  alias show? index?
end
