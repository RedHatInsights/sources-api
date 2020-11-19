class DefaultPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    false
  end
  alias new? create?

  def update?
    false
  end
  alias edit? update?

  def destroy?
    false
  end
  alias delete? destroy?

  def admin?
    return true unless Sources::RBAC::Access.enabled?

    user.system.present? || user.user&.org_admin? || write_access?
  end

  delegate :write_access?, :to => Sources::RBAC::Access

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
