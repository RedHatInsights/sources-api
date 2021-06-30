class DefaultPolicy
  attr_reader :request, :key, :record

  def initialize(context, record)
    @request = context.request
    @key = context.key
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

    if ENV['DISABLE_ORG_ADMIN'] == "true"
      psk_matches? || write_access?
    else
      psk_matches? || request.system.present? || request.user&.org_admin? || write_access?
    end
  end

  def psk_matches?
    return false if self.class.pre_shared_keys.nil?

    self.class.pre_shared_keys.include?(key)
  end

  def self.pre_shared_keys
    # memoizing as a class-var, defaulting to []
    @pre_shared_keys ||= ENV.fetch("SOURCES_PSKS", "").split(",")
  end

  delegate :write_access?, :to => Sources::RBAC::Access

  class Scope
    attr_reader :request, :key, :scope

    def initialize(context, scope)
      @request = context.request
      @key = context.key
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
