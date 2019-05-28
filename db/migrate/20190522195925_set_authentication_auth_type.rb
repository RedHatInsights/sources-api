class SetAuthenticationAuthType < ActiveRecord::Migration[5.2]
  def up
    source_types_by_id        = SourceType.all.index_by(&:id)
    sources_by_source_type_id = Source.all.group_by(&:source_type_id)

    auth_type_by_source_type = {
      "openshift"     => "token",
      "amazon"        => "access_key_secret_key",
      "ansible-tower" => "username_password"
    }

    source_types_by_id.each do |source_type_id, source_type|
      sources = sources_by_source_type_id[source_type_id]
      endpoints = Endpoint.where(:source => sources)
      Authentication.where(:resource => endpoints).update_all(:authtype => auth_type_by_source_type[source_type.name])
    end
  end

  def down
    Authentication.all.update_all(:authtype => nil)
  end
end
