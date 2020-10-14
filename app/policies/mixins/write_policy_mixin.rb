module WritePolicyMixin
  def create?
    admin?
  end
  alias update? create?
  alias destroy? create?
end
