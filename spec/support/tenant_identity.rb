module Spec
  module Support
    module TenantIdentity
      extend ActiveSupport::Concern

      included do
        let!(:tenant)           { Tenant.create!(:external_tenant => external_tenant) }
        let!(:external_tenant)  { rand(1000).to_s }
        let!(:unknown_tenant)   { rand(1000).to_s }
        let!(:identity)         { Base64.encode64({'identity' => { 'account_number' => external_tenant}}.to_json) }
        let!(:unknown_identity) { Base64.encode64({'identity' => { 'account_number' => unknown_tenant}}.to_json) }
      end
    end
  end
end
