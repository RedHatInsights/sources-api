module WritePolicyMixin
  def create?
    system? || admin?
  end

  def update?
    admin?
  end
  alias destroy? update?
  alias pause? update?
  alias unpause? update?
end
