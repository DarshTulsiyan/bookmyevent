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

# Opt-in production provisioning for deployments without console access.
# Remove these environment variables after the admin has been provisioned.
if Rails.env.production? && (ENV["ADMIN_EMAIL"].present? || ENV["ADMIN_PASSWORD"].present?)
  email = ENV.fetch("ADMIN_EMAIL", "").strip.downcase
  password = ENV.fetch("ADMIN_PASSWORD", "")
  raise "Set both ADMIN_EMAIL and ADMIN_PASSWORD to provision the admin" if email.blank? || password.blank?

  admin = User.find_or_initialize_by(email: email)
  admin.name = ENV.fetch("ADMIN_NAME", "BookMyEvent Admin") if admin.new_record?
  admin.role = :admin
  admin.password = password
  admin.password_confirmation = password
  admin.save!
  puts "Production admin provisioned successfully."
elsif Rails.env.production?
  puts "[admin setup] Skipped: ADMIN_EMAIL and ADMIN_PASSWORD are not set on this service."
else
  puts "[admin setup] Skipped: Rails environment is #{Rails.env}, not production."
end
