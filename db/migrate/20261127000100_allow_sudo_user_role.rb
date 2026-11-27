class AllowSudoUserRole < ActiveRecord::Migration[8.1]
  def up
    remove_check_constraint :users, name: "users_role_valid"

    # The integer-backed role enum needs a database constraint for its new value.
    add_check_constraint :users,
                         "role IN (0, 1, 2, 3)",
                         name: "users_role_valid"
  end

  def down
    remove_check_constraint :users, name: "users_role_valid"
    add_check_constraint :users,
                         "role IN (0, 1, 2)",
                         name: "users_role_valid"
  end
end
