module TenancyConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :tenant
    acts_as_tenant :tenant
  end
end
