FactoryBot.define do
  factory :application do
    application_type { association(:application_type) }
    source           { association(:source, :tenant => tenant) }
    tenant           { association(:tenant) }
  end

  factory :application_authentication do
    application    { association(:application, :tenant => tenant) }
    authentication { association(:authentication) }
    tenant         { association(:tenant) }
  end

  factory :application_type do
    name                   { "my-application-type" }
    supported_source_types { ["my-source-type"] }
  end

  factory :authentication do
    username { "test_name" }
    password { "Test Password" }

    tenant   { association(:tenant) }
  end

  factory :endpoint do
    host                  { "example.com" }
    port                  { 443 }
    role                  { "default" }
    path                  { "api" }
    scheme                { "https" }
    verify_ssl            { true }
    certificate_authority { "-----BEGIN CERTIFICATE-----\nabcd\n-----END CERTIFICATE-----" }

    tenant { association(:tenant) }
    source { association(:source, :tenant => tenant) }
  end

  factory :source_type do
    transient do
      compatible { true }
    end

    initialize_with { SourceType.find_or_create_by(:name => name, :product_name => product_name, :vendor => vendor) }

    name         { compatible ? "my-source-type" : "not-my-source-type" }
    product_name { compatible ? "My Source Type" : "Not My Source Type" }
    vendor       { "ACME" }
  end

  factory :source do
    transient do
      compatible { true }
    end

    initialize_with { Source.where(:name => name).first_or_create(:source_type => source_type, :tenant => tenant, :uid => uid) }
    # initialize_with { Source.find_or_create_by(name: name, source_type: source_type, tenant: tenant) }

    source_type { association(:source_type, :compatible => compatible) }
    tenant      { association(:tenant) }
    name        { compatible ? "my-source" : "not-my-source" }
    uid         { SecureRandom.uuid }
  end

  factory :tenant do
    initialize_with { Tenant.where(:name => name).first_or_create(:description => description, :external_tenant => external_tenant) }

    name            { "default" }
    description     { "Test tenant" }
    external_tenant { rand(1000).to_s }
  end

  factory :app_meta_data do
    application_type { association(:application_type) }

    name { "my-custom-metadata" }
    payload { {"account" => 1234} }
  end
end
