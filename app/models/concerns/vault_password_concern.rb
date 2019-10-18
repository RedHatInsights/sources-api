module VaultPasswordConcern
  extend ActiveSupport::Concern

  included do
    after_find  :load_encrypted_columns
    before_save :process_encrypted_columns
    after_save  :save_encrypted_columns

    class_attribute :encrypted_columns
    self.encrypted_columns = []

    Vault.address = "http://127.0.0.1:8200"      # Also reads from ENV["VAULT_ADDR"]
    Vault.token   = "s.D1HV4tdV2TeaAJO12njDN1GH" # Also reads from ENV["VAULT_TOKEN"]
  end

  private

  def load_encrypted_columns
    self.class.encrypted_columns.each do |col|
      send("#{col}_encrypted=", read_attribute(col))
      write_attribute(col, read_from_vault(col))
    end
  end

  def process_encrypted_columns
    self.class.encrypted_columns.each do |col|
      send("#{col}_encrypted=", read_attribute(col)) # copy unencrypted value
      write_attribute(col, "******")                 # obfuscate  encrypted column
    end
  end

  def save_encrypted_columns
    self.class.encrypted_columns.each do |col|
      write_to_vault(col, send("#{col}_encrypted"))
      write_attribute(col, send("#{col}_encrypted")) # put unencrypted value back in column
    end
  end

  def read_from_vault(attr)
    Vault.kv("secret").read(vault_key).try(:data).try(:[], attr.to_sym)
  end

  def write_to_vault(attr, val)
    Vault.kv("secret").write(vault_key, attr.to_sym => val)
  end

  def vault_key
    "#{self.class.table_name}_#{id}"
  end

  module ClassMethods
    def encrypt_column(column)
      encrypted_columns << column.to_s
      class_eval { attr_accessor "#{column}_encrypted" }
    end
  end
end
