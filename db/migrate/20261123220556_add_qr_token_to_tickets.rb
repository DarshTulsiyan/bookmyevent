class AddQrTokenToTickets < ActiveRecord::Migration[8.1]
  def up
    add_column :tickets, :qr_token, :string

    execute <<~SQL
      UPDATE tickets
      SET qr_token = md5(random()::text || clock_timestamp()::text || id::text)
    SQL

    change_column_null :tickets, :qr_token, false

    add_index :tickets, :qr_token, unique: true
  end

  def down
    remove_index :tickets, :qr_token
    remove_column :tickets, :qr_token
  end
end
