class MoveArnAuthToUsername < ActiveRecord::Migration[5.2]
  def up
    Authentication.transaction do
      Authentication.where(:authtype => %w[arn cloud-meter-arn]).each do |auth|
        # skip if the resource doesn't exist. e.g. it's a dangling auth
        next if auth.resource.nil?

        auth.update!(:username => auth.password)
      end
    end
  end

  def down
    Authentication.transaction do
      Authentication.where(:authtype => %w[arn cloud-meter-arn]).each do |auth|
        # skip if the resource doesn't exist. e.g. it's a dangling auth
        next if auth.resource.nil?

        auth.update!(:username => nil)
      end
    end
  end
end
