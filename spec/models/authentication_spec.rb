describe Authentication do
  describe VaultPasswordConcern do
    before do
      stub_const("ENV", "VAULT_ADDR" => "http://127.0.0.1:8200")
      Object.send(:remove_const, :Authentication) if Module.const_defined?(:Authentication)
      load "authentication.rb"
    end

    after do
      stub_const("ENV", "VAULT_ADDR" => nil)
      Object.send(:remove_const, :Authentication) if Module.const_defined?(:Authentication)
      load "authentication.rb"
    end

    let(:tenant)      { Tenant.create!(:name => "default", :external_tenant => "123456") }
    let(:source_type) { SourceType.create!(:name => "SourceType", :vendor => "Some Vendor", :product_name => "Product Name") }
    let(:source)      { Source.create!(:name => "My Source", :source_type => source_type, :tenant => tenant) }
    let(:endpoint)    { Endpoint.create!(:source => source, :tenant => tenant) }

    context "creating an authentication" do
      let(:password)  { "smartvm" }
      let(:auth)      { Authentication.create!(:resource => endpoint, :password => password, :tenant => tenant) }
      let(:vault_key) { "authentications_99" }
      let(:dbl)       { double("Vault::KV") }


      it "should write unencrypted password to the vault" do
        allow_any_instance_of(Authentication).to receive(:vault_key).and_return(vault_key)
        allow(Vault).to receive(:kv).with("secret").and_return(dbl)

        expect(dbl).to receive(:write).with(vault_key, :password => password)
        expect(auth.password).to eq(password)
      end

      it "obfuscate password in the database" do
        allow_any_instance_of(Authentication).to receive(:vault_key).and_return(vault_key)
        allow(Vault).to receive(:kv).with("secret").and_return(dbl)
        allow(dbl).to receive(:write)
        expect(dbl).to receive(:read)
        expect(Authentication.find(auth.id).password_encrypted).to eq("******")
      end
    end

    context "an existing authentication" do
      it "retrieves password from vault" do
        # TODO
      end

      it "no vault entry returns nil for password" do
        # TODO
      end
    end
  end
end
