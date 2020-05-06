class RenameSatelliteInitialValue < ActiveRecord::Migration[5.2]
  def up
    rename("sattelite", "satellite")
  end

  def down
    rename("satellite", "sattelite")
  end

  def rename(old, new)
    SourceType.where(:name => "satellite").each do |type|
      type.schema["endpoint"]["fields"].each do |field|
        field["initialValue"] = new if field["initialValue"] == old
      end
      type.save!
    end
  end
end
