describe Authentication do
  describe VaultPasswordConcern do
    let(:test_vault_password_class) do
      Class.new(ActiveRecord::Base) do
        def self.name; "TestClass"; end
        self.table_name = "authentications"
        include TenancyConcern
        include VaultPasswordConcern
        encrypt_column :password
      end
    end

    let(:tenant)      { Tenant.create!(:name => "default", :external_tenant => "123456") }

    context "creating an authentication" do
      let(:password)  { "smartvm" }
      let(:auth)      { test_vault_password_class.create!(:password => password, :tenant => tenant) }
      let(:vault_key) { "authentications_99" }
      let(:dbl)       { double("Vault::KV") }


      it "should write unencrypted password to the vault" do
        allow_any_instance_of(test_vault_password_class).to receive(:vault_key).and_return(vault_key)
        allow(Vault).to receive(:kv).with("secret").and_return(dbl)

        expect(dbl).to receive(:write).with(vault_key, :password => password)
        expect(auth.password).to eq(password)
      end

      it "obfuscate password in the database" do
        allow_any_instance_of(test_vault_password_class).to receive(:vault_key).and_return(vault_key)
        allow(Vault).to receive(:kv).with("secret").and_return(dbl)
        allow(dbl).to receive(:write)
        expect(dbl).to receive(:read)
        expect(test_vault_password_class.find(auth.id).password_encrypted).to eq("******")
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
