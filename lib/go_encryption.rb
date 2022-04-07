class GoEncryption
  def self.encrypt(pass)
    # clowder can throw error messages - so we filter them out
    %x[sources-encrypt-compat -encrypt #{pass} | grep -v Clowder].strip.tap do |str|
      raise "error encrypting string: #{str}" if $?.to_i != 0
      raise "bad encryption!" if str.blank?
    end
  end

  def self.decrypt(pass)
    # clowder can throw error messages - so we filter them out
    %x[sources-encrypt-compat -decrypt #{pass} | grep -v Clowder].strip.tap do |str|
      raise "error encrypting string: #{str}" if $?.to_i != 0
      raise "bad encryption!" if str.blank?
    end
  end
end
