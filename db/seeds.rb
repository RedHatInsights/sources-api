# Run all seed files in db/seeds/*.rb
Dir[Rails.root.join("db", "seeds", "**", "*.rb")].each { |f| require f }
