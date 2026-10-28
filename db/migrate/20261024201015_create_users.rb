class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.boolean :suspended, null: false, default: false

      t.timestamps
    end

    add_index :users, "lower(email)",
              unique: true,
              name: "index_users_on_lower_email"

    add_check_constraint :users,
                        "role IN (0, 1, 2)",
                        name: "users_role_valid"
  end 
end
