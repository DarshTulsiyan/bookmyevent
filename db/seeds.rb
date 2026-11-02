# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create the default admin only in development, never in production.
if Rails.env.development?
  admin = User.find_or_initialize_by(email: "admin@bookmyevent.com")
  admin.name = "BookMyEvent Admin"
  admin.role = :admin
  admin.password = "admin@123"
  admin.save!
end
