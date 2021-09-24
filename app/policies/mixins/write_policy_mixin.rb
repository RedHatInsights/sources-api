module WritePolicyMixin
  def create?
    admin? || system?
  end

  def update?
    admin?
  end
  alias destroy? update?
  alias pause? update?
  alias unpause? update?
end
