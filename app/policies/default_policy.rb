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

  ALLOWED_AUTHTYPES = %w[cluster_id cn].freeze

  def system?
    return false unless request.identity["identity"]

    request.identity["identity"]["system"] && supported_authtype?
  rescue Insights::API::Common::IdentityError # this crops up if the request does NOT have x-rh-identity
    false
  end

  def supported_authtype?
    ALLOWED_AUTHTYPES.any? { |type| request.identity["identity"]["system"].key?(type) }
  end

  def admin?
    return true unless Sources::RBAC::Access.enabled?

    psk_matches? || write_access?
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
