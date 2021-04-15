module WritePolicyMixin
  def create?
    admin?
  end
  alias update? create?
  alias destroy? create?
  alias pause? create?
  alias unpause? create?
end
