class CreateAdminAccessRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin_access_request_reviewer, :boolean, default: false, null: false

    create_table :admin_access_requests do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :reason, null: false
      t.string :password_digest
      t.integer :status, default: 0, null: false
      t.text :reviewer_note
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :admin_access_requests,
              "lower(email)",
              unique: true,
              where: "status = 0",
              name: "index_admin_access_requests_on_pending_email"
    add_check_constraint :admin_access_requests,
                         "status IN (0, 1, 2)",
                         name: "admin_access_requests_status_valid"
  end
end
