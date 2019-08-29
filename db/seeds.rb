# Run all seed files in db/seeds/*.rb
Dir[File.join(Rails.root.join("db", "seeds"), "**/*.rb")].each { |f| load f }
