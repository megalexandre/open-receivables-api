RSpec.configure do |config|
  config.before(:suite) do
    conn = ActiveRecord::Base.connection
    conn.execute("SET FOREIGN_KEY_CHECKS = 0")
    conn.tables.each do |table|
      next if %w[ar_internal_metadata schema_migrations].include?(table)
      conn.execute("TRUNCATE TABLE #{table}")
    end
    conn.execute("SET FOREIGN_KEY_CHECKS = 1")
  end
end
